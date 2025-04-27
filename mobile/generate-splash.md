# If you have a flavor called production you would do this:
```bash
dart run flutter_native_splash:create --flavor production
```

# For a flavor with a name staging you would provide it's name like so:
```bash
dart run flutter_native_splash:create --flavor acceptance
```

# And if you have a local version for devs you could do that:
```bash
dart run flutter_native_splash:create --flavor development
```

# You also have the ability to specify all the flavors in one command as shown bellow:
```bash
dart run flutter_native_splash:create --flavors development,staging,production
```

# (And if you have many different flavors available in your project, and wish to generate the splash screen for all of them, you can use this command &#40;starting from 2.4.4&#41;:)
```bash
dart run flutter_native_splash:create --all-flavors
# OR you can use the shorthand option
dart run flutter_native_splash:create -A
```

https://pub.dev/packages/flutter_native_splash