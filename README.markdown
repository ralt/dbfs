# dbfs

## Spec

/pkg/: list of tables
/pkg/[table-name]/structure/: table's structure
/pkg/[table-name]/structure/[field-name]: meta-data of the field (e.g. primary key)
/pkg/[table-name]/id: file defining on which field(s) the filenames will be based on in data/. This will be guessed based on the primary key(s) if possible.
/pkg/[table-name]/data/: data of the table
/pkg/[table-name]/data/[id]: data of the row

## Author

* Florian Margaine (florian@margaine.com)

## Copyright

Copyright (c) 2015 Florian Margaine (florian@margaine.com)

## License

Licensed under the MIT License.
