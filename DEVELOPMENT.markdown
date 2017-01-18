# Development

## ENV

Ensure common path variables defined on terminal session start.

```

    $ atom ~/.process
    export DEV_HOME=~/Documents/webdev
    export PIKTUR_HOME=$DEV_HOME/current_projects/piktur

```

## Ruby

### Linting

```yaml

    inherit_from:
      - '~/Documents/webdev/.rubocop.yml'

```


## Node

### Linting

```sh
  # Install `eslint` globally
  npm install -g eslint

  # Install Airbnb config globally
  export PKG=eslint-config-airbnb;
  npm info "$PKG@latest" peerDependencies --json | command sed 's/[\{\},]//g ; s/:/@/g' | xargs npm install -g "$PKG@latest"
```

```javascript

    module.exports = {
      extends: `~/Documents/webdev/.eslintrc.base.js`,
      rules: {
        // ... project specific rules below
      }
    };

```
