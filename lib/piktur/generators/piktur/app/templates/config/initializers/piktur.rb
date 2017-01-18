# frozen_string_literal: true

module Piktur

  module Settings

    # Account::Base.configure do |c|
    #   c.locale = :en
    #   c.syntax = :markdown
    #   c.timezone = 'Sydney'
    # end

    # Asset::Base.configure do |c|
    #   lib = Piktur::Engine.root.join('lib', 'piktur')
    #
    #   c.audio_processor = ''
    #   c.audio_versions = {}
    #   c.document_processor = ''
    #   c.document_versions = {}
    #   c.icc_profile = lib.join('processors/image/sRGB_IEC61966-2-1_black_scaled.icc').to_s
    #   c.image_processor = lib.join('processors/image/sharp.js').to_s
    #   # @todo configure CSS media query breakpoints
    #   c.image_versions = {
    #     # original: {},
    #     # Placeholder
    #     tmp: {
    #       enabled:      true,
    #       minDimension: 42,
    #       quality:      10,
    #       retina:       false,
    #       webp:         true
    #     },
    #     # Background
    #     bg: {
    #       # crop:       false,
    #       enabled:      true,
    #       # extract:    [nil, nil, nil,],
    #       # gravity:    [nil, nil],
    #       greyscale:    true,
    #       minDimension: 1024,
    #       quality:      50,
    #       retina:       true,
    #       sharpen:      true,
    #       webp:         true
    #     },
    #     # Cropped
    #     crop: {
    #       crop:         true,
    #       # extract:    [nil, nil, nil,],
    #       enabled:      true,
    #       # gravity:    %w(center center),
    #       minDimension: 512,
    #       quality:      90,
    #       retina:       true,
    #       sharpen:      true,
    #       webp:         true
    #     },
    #     # Thumbnail
    #     sml: {
    #       enabled:      true,
    #       minDimension: 256,
    #       quality:      85,
    #       retina:       true,
    #       sharpen:      true,
    #       webp:         true
    #     },
    #     med: {
    #       enabled:      true,
    #       minDimension: 768,
    #       quality:      90,
    #       sharpen:      true,
    #       retina:       true,
    #       webp:         true
    #     },
    #     lrg: {
    #       enabled:      true,
    #       minDimension: 1024,
    #       quality:      90,
    #       sharpen:      true,
    #       retina:       true,
    #       webp:         true
    #     },
    #     # Canonical image for search engines
    #     index: {
    #       enabled:      true,
    #       minDimension: 1024,
    #       quality:      100,
    #       sharpen:      true,
    #       retina:       false,
    #       webp:         false
    #     },
    #     # Tiled DZI archive
    #     zoom: {
    #       enabled:      true,
    #       quality:      90,
    #       retina:       false,
    #       webp:         false
    #     }
    #   }
    #   c.video_processor = ''
    #   c.video_versions = {}
    # end

    # Blog.configure do |c|
    #   # c.setting = ""
    # end

    # Generator.configure do |c|
    #   c.build_dir = '/public'
    #   c.https = true
    # end

    # Site::Base.configure do |c|
    #   # Search filters
    #   c.filters = [
    #     :year,
    #     :artform,
    #     :material,
    #     :size,
    #     :colour,
    #     :availability,
    #     :price_range,
    #     :tag,
    #     :catalogue
    #   ]
    #   c.locale = :en
    #   c.promote = true
    #   c.public = true
    #   c.rss = true
    #   c.shareable = true
    #   c.subscribable = true
    #   c.timezone = 'Sydney'
    #   c.pages = [
    #     {
    #       active: true,
    #       klass: 'About',
    #       title: 'About',
    #       menu_item: true,
    #       sub_pages: [
    #         {
    #           active: true,
    #           klass: 'Bio',
    #           title: 'Bio',
    #           menu_item: false
    #         },
    #         {
    #           active: true,
    #           klass: 'Cv',
    #           title: 'Cv',
    #           menu_item: false
    #         },
    #         {
    #           active: true,
    #           klass: 'Statement',
    #           title: 'Statement',
    #           menu_item: false
    #         }
    #       ]
    #     },
    #     {
    #       active: true,
    #       klass: 'Contact',
    #       title: 'Contact',
    #       menu_item: true
    #     },
    #     {
    #       active: true,
    #       klass: 'Legal',
    #       title: 'Legal',
    #       menu_item: false,
    #       # sub_pages: [
    #       #   {
    #       #     active: true,
    #       #     klass: '',
    #       #     title: 'Copyright',
    #       #     menu_item: false
    #       #   },
    #       #   {
    #       #     active: true,
    #       #     klass: '',
    #       #     title: 'Privacy',
    #       #     menu_item: false
    #       #   },
    #       #   {
    #       #     active: true,
    #       #     klass: '',
    #       #     title: 'Returns',
    #       #     menu_item: false
    #       #   },
    #       #   {
    #       #     active: true,
    #       #     klass: '',
    #       #     title: 'Shipping',
    #       #     menu_item: false
    #       #   }
    #       # ]
    #     },
    #     {
    #       active: true,
    #       klass: 'Gallery',
    #       title: 'Gallery',
    #       menu_item: true,
    #       sub_pages: [
    #         {
    #           active: true,
    #           klass: 'Portfolio',
    #           title: 'Portfolios',
    #           menu_item: true,
    #           sub_pages: [
    #             {
    #               active: true,
    #               klass: 'Artwork',
    #               title: 'Artworks',
    #               menu_item: false,
    #               sub_pages: [
    #                 {
    #                   active: true,
    #                   klass: 'Detail',
    #                   title: 'Details',
    #                   menu_item: false
    #                 },
    #                 {
    #                   active: true,
    #                   klass: 'Video',
    #                   title: 'Videos',
    #                   menu_item: false
    #                 }
    #               ]
    #             },
    #             {
    #               active: true,
    #               klass: 'Commentary',
    #               title: 'Commentaries',
    #               menu_item: false
    #             },
    #             {
    #               active: true,
    #               klass: 'Demonstration',
    #               title: 'Demonstrations',
    #               menu_item: false
    #             },
    #             {
    #               active: true,
    #               klass: 'Interview',
    #               title: 'Interviews',
    #               menu_item: false
    #             },
    #             {
    #               active: true,
    #               klass: 'Study',
    #               title: 'Studies',
    #               menu_item: false
    #             },
    #             {
    #               active: true,
    #               klass: 'Video',
    #               title: 'Videos',
    #               menu_item: false
    #             }
    #           ]
    #         },
    #         {
    #           active: true,
    #           klass: 'Event',
    #           title: 'Events',
    #           menu_item: true,
    #           sub_pages: [
    #             {
    #               active: true,
    #               klass: 'Commentary',
    #               title: 'Commentaries',
    #               menu_item: false
    #             },
    #             {
    #               active: true,
    #               klass: 'Document',
    #               title: 'Documents',
    #               menu_item: false
    #             },
    #             {
    #               active: true,
    #               klass: 'Demonstration',
    #               title: 'Demonstrations',
    #               menu_item: false
    #             },
    #             {
    #               active: true,
    #               klass: 'Installation',
    #               title: 'Installations',
    #               menu_item: false
    #             },
    #             {
    #               active: true,
    #               klass: 'Interview',
    #               title: 'Interviews',
    #               menu_item: false
    #             },
    #             {
    #               active: true,
    #               klass: 'Study',
    #               title: 'Studies',
    #               menu_item: false
    #             }
    #           ]
    #         }
    #       ]
    #     },
    #     {
    #       active: true,
    #       klass: 'Store',
    #       title: 'Store',
    #       menu_item: true
    #     }
    #   ]
    #   c.global_styles = {
    #     colors: {
    #       primary: 'black',
    #       secondary: 'red',
    #       brand: 'blue'
    #     },
    #     typography: {
    #       headings: {
    #         site: {
    #           font_family: 'Lato',
    #           font_size: '',
    #           color: '',
    #           font_weight: '',
    #           font_style: '',
    #           letter_spacing: '',
    #           text_align: ''
    #         },
    #         page: {
    #           font_family: 'Lato',
    #           font_size: '',
    #           color: '',
    #           font_weight: '',
    #           font_style: '',
    #           letter_spacing: '',
    #           text_align: ''
    #         }
    #       },
    #       body: {
    #         font_family: 'Lato',
    #         font_size: '',
    #         color: '',
    #         font_weight: '',
    #         font_style: '',
    #         letter_spacing: '',
    #         text_align: ''
    #       },
    #       small: {
    #         font_family: 'Lato',
    #         font_size: '',
    #         color: '',
    #         font_weight: '',
    #         font_style: '',
    #         letter_spacing: '',
    #         text_align: ''
    #       },
    #       link: {
    #         font_family: 'Lato',
    #         font_size: '',
    #         color: '',
    #         font_weight: '',
    #         font_style: '',
    #         letter_spacing: '',
    #         text_align: '',
    #         hover: {
    #           color: ''
    #         },
    #         active: {
    #           color: ''
    #         },
    #         visited: {
    #           color: ''
    #         }
    #       }
    #     },
    #     borders: {
    #       color: '',
    #       width: '',
    #       radius: '',
    #       style: ''
    #     },
    #     background: {
    #       image: '',
    #       color: ''
    #     },
    #     box: {
    #       margin: '',
    #       padding: '',
    #       border: '',
    #       width: '',
    #       overflow: ''
    #     }
    #   }
    # end

    # Store.configure do |c|
    #   c.trading = true
    # end

  end

end
