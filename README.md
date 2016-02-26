(Thanks Rob Haswell)

## Quickstart

The user must specify authentication credentials via the following environment variables:

```
USERNAME=foo
PASSWORD=bar
```

An example invocation would be:

```
docker run -e USERNAME=foo -e PASSWORD=bar -p 3128:3128 --volume /srv/docker/squid/:/squid babim/squid:auth
```

Volume dir:
```
/squid/cache
/squid/log
/squid/config
```

User default (if not set) = user
Password default (if not set) = password
