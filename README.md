## DATEX

Textual database library for Shell Script, written in BASH and AWK.

**Setup and Usage**

Just clone this project to your preferred folder:

    git clone https://github.com/facmachado/datex.git

And include it in your project:

    DBFILE=path/to/database.csv
    source datex/datex.sh

**Commands**

    create_header <field1> [field2] [field3] ...

Generates the header with required fields (CSV format)

    list_records [lines] [start]

List (non-"deleted") records, each field per line (params optional)

    search_records <query>

List the records, searching a keyword

    select_record <id>

Shows requested record, if not "deleted"

    insert_record <field1=value1> [field2=value2] [field3=value3] ...

Adds a new record

    update_record <id> <field1=value1> [field2=value2] [field3=value3] ...

Changes data inside the record

    delete_record <id>

"Deletes" the record (marks for manual recovery)

**Limitations**

This is intended for simple CSV file handlings. It can be used as a backend for tiny systems, catalogues etc., but DO NOT expect security or database rules here, although in a well-configured CGI the access to the CSV files should be protected anyway.

**TODOs**

 - Functions for authentication, logging and config files
 - HTML and XML outputs in mind
 - CSV and JSON outputs ready

**About**

I was implementing the datex backend in another project; but when I became marvelled with the result, I decided to move it to an independent one (this here).

I earlier had also given up this project, until I discovered the ease of the AWK language.

This project was inspired by [Aurelio's](https://aurelio.net/) [bantex.sh](https://github.com/aureliojargas/livro-shell/tree/master/10-banco) (from his ["Professional Shell Script"](https://aurelio.net/shell/) book, in portuguese).

I cannot forget an answer I found at [Stack Overflow](https://stackoverflow.com/a/36049307).

**Developer**

Flavio Augusto ([@facmachado](https://twitter.com/facmachado))

**License**

MIT
