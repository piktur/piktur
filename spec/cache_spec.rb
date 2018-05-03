# frozen_string_literal: true

require 'benchmark'
require 'benchmark/ips'
require 'active_support/all'

module Cache

  require 'dry/core/cache'

  N = 100

  A = ActiveSupport::Cache::MemoryStore.new
  B = Class.new { extend Dry::Core::Cache }
  C = Concurrent::Map.new
  D = Hash.new
  E = Mutex.new

  TESTS = {
    'ActiveSupport::Cache::MemoryStore#fetch' => proc { A.fetch(:a) { 1 } },
    'Dry::Core::Cache#fetch_or_store' => proc { B.fetch_or_store(:a) { 1 } },
    'Concurrent::Map#fetch_or_store' => proc { C.fetch_or_store(:a) { 1 } },
    'Hash#[]' => proc { D[:a] ||= 1 },
    'Hash#[] concurrent' => proc { E.synchronize { D[:a] ||= 1 } }
  }

  class << self

    def ips
      Benchmark.ips do |x|
        TESTS.each do |name, block|
          x.report(name, &block)
          x.compare!
        end
      end
    end

    def bmbm
      Benchmark.bmbm do |x|
        TESTS.each do |name, block|
          x.report(name) { N.times(&block) }
        end
      end
    end

  end

end

module CacheKeyHashing

  require 'digest'
  require 'base64'
  require 'active_support/core_ext/digest/uuid'

  N = 100

  STR    = [0, 'ActiveRecord', :client, :show].inspect
  SECRET = '00'

  TESTS = {
    'String.crypt' => proc { STR.crypt(SECRET) },
    'Base64.encode64' => proc { Base64.encode64(STR) },
    'Digest.hexencode' => proc { Digest.hexencode(STR) },
    'Digest::MD5.hexdigest' => proc { Digest::MD5.hexdigest(STR) },
    'Digest::SHA1.hexdigest' => proc { Digest::SHA1.hexdigest(STR) }
  }

  class << self

    def dup_will_produce_the_same_base64_hash
      original = CacheKeyHashing::STR.dup
      copy     = original.dup
      stored   = Base64.encode64(original)
      query    = Base64.encode64(copy)

      Base64.decode64(stored) == Base64.decode64(query)
    end

    def dup_will_produce_the_same_hash
      original = CacheKeyHashing::STR.dup
      copy     = original.dup
      stored   = Digest.hexencode(original)
      query    = Digest.hexencode(copy)

      stored == query
    end

    def routes_cache(ips = true)
      method = :hexdigest

      Piktur::API::Routing.singleton_class.class_eval do
        define_method(:_hash) do |*args|
          case method
          when :hexdigest then Digest::MD5.hexdigest(args.to_s)
          when :hexencode then Digest.hexencode(args.to_s)
          when :uuid_v5   then Digest::UUID.uuid_v5('piktur.io', 'a')
          end
        end
        private :_hash
      end

      reload = proc do
        Rails.application.reload_routes!
        Rails.application.routes.routes
      end

      digest_md5_hexdigest = proc do
        method = :hexdigest
        reload.call
      end

      digest_hexencode = proc do
        method = :hexencode
        reload.call
      end

      digest_uuid_v5 = proc do
        method = :uuid_v5
        reload.call
      end

      if ips
        Benchmark.ips do |x|
          x.report('Digest.hexencode', &digest_hexencode)
          x.report('Digest::MD5.hexdigest', &digest_md5_hexdigest)
          x.report('Digest::UUID.uuid_v5', &digest_uuid_v5)
          x.compare!
        end
      else
        Benchmark.bmbm do |x|
          x.report('Digest.hexencode') { N.times(&digest_hexencode) }
          x.report('Digest::MD5.hexdigest') { N.times(&digest_md5_hexdigest) }
          x.report('Digest::UUID.uuid_v5') { N.times(&digest_uuid_v5) }
        end
      end
    end

    def rand
      Benchmark.ips do |x|
        x.report('rand') { rand }
        x.report('Time.now') { Time.now }
        x.report('Time.now.to_i') { Time.now.to_i }
        x.report('Time.now.utc') { Time.now.utc }
        x.compare!
      end
    end

    def ips
      Benchmark.ips do |x|
        TESTS.each do |name, block|
          x.report(name, &block)
          x.compare!
        end
      end
    end

    def bmbm
      Benchmark.bmbm do |x|
        TESTS.each do |name, block|
          x.report(name) { N.times(&block) }
        end
      end
    end

  end

end

Cache.module_eval do
  describe self do
    def set(value)
      cache.send(method, :a) { value }
    end

    def get
      cache.send(method, :a)
    end

    shared_examples 'concurrency' do
      let(:value) { rand }

      it do
        set(value)
        10.times { Thread.new { set(rand) } }
        expect(get).to be(value)
      end
    end

    shared_examples 'clustered' do
      let(:value) { rand }

      it do
        set(value)
        pid = fork { set(rand) }
        pid, status = Process.wait2(pid)
        expect(get).to be(value)
      end
    end

    described_class::TESTS.each do |name, block|
      describe name do
      end
    end

    describe 'ActiveSupport::Cache::MemoryStore#fetch' do
      let(:cache) { described_class::A }
      let(:method) { :fetch }

      include_examples 'concurrency'
      # include_examples 'clustered'
    end

    describe 'Dry::Core::Cache#fetch_or_store' do
      let(:cache) { described_class::B }
      let(:method) { :fetch_or_store }

      include_examples 'concurrency'
      # include_examples 'clustered'
    end
  end
end
