# Docker Deployment for Laravel Applications

This repository implements Docker containers to facilitate the deployment of Laravel applications. It's goal is to be useful for creating both development and production environments.

## How to Install

### Download

To get started, clone the `hawara/docker-laravel` repository.

```bash
# Using SSH
git clone git@github.com:hawara-es/docker-laravel.git

# ... or HTTPS
git clone https://github.com/hawara-es/docker-laravel.git
```

### Customize

Once you have the repository, use the `create-environment` script to create:

- an environment file, `.env`, with random passwords to speed up the installation,
- a `docker-laravel` script to manage your containers.

Call the script by running `./create-environment` from the terminal followed by the names of the services separated by spaces.

```bash
./create-environment mysql
```

Available services are:

- `letsencrypt`: installs Let's Encrypt `certbot` utility to facilitate serving the application through HTTPS,
- `mysql`: runs a MySQL database server,
- `redis`: runs a Redis server,
- `supervisor`: runs a Supervisor instance checking Laravel's queues.

Also, this features are available:

- `dev`: enables XDebug and opens MySQL port to the host,
- `mailhog`: enables a MailHog email catcher,

Finally, you can choose how your volumes will be handled:

- `volume-on-container`: keeps the volumes in the containers,
- `volume-on-host`: uses volumes shared with the host.

#### Environment Variables

When you created the environment, a new `.env` file was created with some random passwords. The file is as basic as possible, so you must check it and complete it with all the variables that your Laravel application needs.

### Build

Now you should have a custom `docker-laravel` script that will help you when interacting with your containers. For instance, you can now build the selected containers.

```bash
./docker-laravel build
```

#### Install from Composer

By calling `build` without arguments, a new Laravel application will be installed using Composer in your webroot.

In other words, the build process would be executed as if `install_method` was set to **composer** and `install_from_composer` was set to **laravel/laravel**.

```bash
./docker-laravel build \
    --build-arg install_method=composer \
    --build-arg install_from_composer=laravel/laravel
```

You can change `laravel/laravel` to be the source of your custom Laravel application. Just check that it's a publicly available Composer package.

#### Install from a Custom Composer Repository

If your application is a Composer package but it isn't in Packagist, use the **composer_repo** installation method instead. Also, use `install_from_composer_repo` to tell Docker where are your sources.

```bash
./docker-laravel build \
    --build-arg install_method=composer_repo \
    --build-arg install_from_composer_repo=https://github.com/laravel/laravel
```

#### Install from a Custom Git Repository

Alternativelly, you can tell the installer to use the **git** installation method. By doing so, the application specified in `install_from_git` would be installed.

```bash
./docker-laravel build \
    --build-arg install_method=git \
    --build-arg install_from_git=https://github.com/laravel/laravel
```

#### Manuall Install

Ultimately, you can delay the installation to make it happen manually by using the `manual` installation method.

```bash
./docker-laravel build \
    --build-arg install_method=manual
```

If you do so, you will very likely want to use the `volume-on-host` service when creating your environment. That will mount the `volumes/application` folder as your container's web root.

Make sure to place your application so it has a `public` folder, as the web server is configured to publish it. At this point, to continue with the installation, we'll start the containers.

```bash
./docker-laravel up -d
```

Temporarily, our web server container may report unhealthy. That's just because we still don't have anything in the web root.

As an example, let's install a clean new Laravel manually:

```sh
# 1) Create the project in a new folder (here `download`)
./composer create-project laravel/laravel download/

# 2) Open a shell in the PHP container
./shell php

# 3) Move the files and leave things clean
cp -R download/* . && rm -rf download/

# 4) Generate the application keys
./artisan key:generate
```

### Start the Services

If you are following this guide but you are not doing a manual installation, you may want to start your containers. That will make your application available.

```bash
./docker-laravel up -d
```

### Check the Services

This repository implements health checks for MySQL, Nginx and PHP FPM. If you run a `ps` in Docker, you should see each service status.

```bash
./docker-laravel ps
```

![List of for containers Cron, MySQL, Nginx and PHP running in a healthy state](./docker-images/containers_screenshot.png)

## How to Use

### Run `artisan` Commands

All `artisan` commands can be called using the so-called helper.

```bash
./artisan key:generate
```

### Run `composer` Commands

Also, all `composer` commands can be called using the so-called helper.

```bash
./composer update
```

### Open `shell` Sessions

To administrate the containers, `shell` sessions can be created.

```bash
# Open a shell in the `php` container
./shell php

# ... or in the `nginx` container
./shell nginx
```
