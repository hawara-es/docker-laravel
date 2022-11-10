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

## TODO:

- [ ] Create a `volume-on-host` install method
- [ ] Document build arguments (install_method, etc)