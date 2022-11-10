# Deploy Laravel Applications with Docker

## How to Install

Clone the `hawara/docker-laravel` repository.

```bash
# Using SSH
git clone git@github.com:hawara-es/docker-laravel.git

# ... or HTTPS
git clone https://github.com/hawara-es/docker-laravel.git
```

The `create-environment` script can help you creating:

- an environment file, `.env`, with random passwords to speed up the installation,
- a `docker-laravel` script to manage your containers.

```bash
./create-environment mysql redis dev
```

Now, you can use your custom `docker-laravel` script to build your image.

```bash
./docker-laravel build
```

### Building Options

By calling `build` without arguments, a new Laravel application will be installed using Composer in your webroot.

#### Install from Composer

In other words, the build process would be executed as if `install_method` was set to **composer** and `install_from_composer` was set to **laravel/laravel**.

```bash
./docker-laravel build \
    --build_args install_method=composer \
    --build_args install_from_composer=laravel/laravel
```

You can change `laravel/laravel` to be the source of your custom Laravel application. Just check that it's a publicly available Composer package.

#### Install from a Custom Composer Repository

If your application is a Composer package but it isn't in Packagist, use the **composer_repo** installation method instead. Also, use `install_from_composer_repo` to tell Docker where are your sources.

```bash
./docker-laravel build \
    --build_args install_method=composer_repo \
    --build_args install_from_composer_repo=https://github.com/laravel/laravel
```

#### Install from a Custom Git Repository

Alternativelly, you can tell the installer to use the **git** installation method. By doing so, the application specified in `install_from_git` would be installed.

```bash
./docker-laravel build \
    --build_args install_method=git \
    --build_args install_from_git=https://github.com/laravel/laravel
```

Finally, you can now start your services.

```bash
./docker-laravel up -d
```

## How to Use

All `artisan` commands can be called using the so-called helper.

```bash
./artisan key:generate
```

To administrate the containers, `shell` sessions can be created.

```bash
# Open a shell in the `php` container
./shell php

# ... or in the `nginx` container
./shell nginx
```
