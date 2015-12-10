# Deploying Elixir Mix project on Dokku
## Setup VPS

Create clean Ubuntu 14.04 image on Digital Ocean or any other VPS.

Login to VPS via ssh:
```
$ ssh root@server_ip
```

Install [Dokku](https://github.com/dokku/dokku):
```sh
$ wget https://raw.githubusercontent.com/dokku/dokku/v0.4.5/bootstrap.sh
$ sudo DOKKU_TAG=v0.4.5 bash bootstrap.sh
```

Create a Dokku app:
```
$ dokku apps:create app_name
```

Make it support multiple buildpacks:
```
$ dokku config:set app_name BUILDPACK_URL=https://github.com/ddollar/heroku-buildpack-multi.git
```

Ensure your locale is set to UTF-8:
```
$ dokku config:set app_name LC_ALL=en_US.utf8
```

Set prod env:
```
$ dokku config:set app_name MIX_ENV=prod
```

Put any ENV keys to app config:
```
$ dokku config:set app_name SECRET_KEY=secret
```

## Add changes to your git repository on local computer

Create .buildpacks file:
```
$ echo "https://github.com/HashNuke/heroku-buildpack-elixir.git" >> .buildpacks
```

Ensure you have `prod.secret.exs` in git. Replace all ENV keys with `System.get_env("SECRET_KEY")`

**Commit changes** and add git remote:
```
$ git remote add dokku dokku@server_ip:app_name
```

Deploy your app to Dokku:
```
$ git push dokku master
```
