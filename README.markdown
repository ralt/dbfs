# dbfs

Database as a filesystem.

## Spec

Will surely change as I iterate on the thing.

- /db/: list of tables
- /db/[table-name]/structure/: table's structure
- /db/[table-name]/structure/[field-name]: meta-data of the field (e.g. primary key)
- /db/[table-name]/id: file defining on which field(s) the filenames will be based on in data/. This will be guessed based on the primary key(s) if possible.
- /db/[table-name]/data/: data of the table
- /db/[table-name]/data/[id]: data of the row

## Author

* Florian Margaine (florian@margaine.com)

## Copyright

Copyright (c) 2015 Florian Margaine (florian@margaine.com)

## License

Licensed under the MIT License.
