# Coversheets

This is an ingredient intended for use with EPrints 3.4+. It is designed to add branded coversheets to PDF documents uploaded to an archive.  It allows coversheet templates to be uploaded and then choose which eprint records these coversheets should be applied.

This ingredient is based on the [original Coversheets Bazaar plugin](https://bazaar.eprints.org/350/).  The main difference is that does not use EPrints' indexer but is instead run periodically from a cron job. This allows for better management of when coversheeting tasks run and also help keep the indexer log clean from a lot of the noise that can be generated from coversheeting, particularly parsing PDF documents.

Thus ingredients also requires the [openoffice ingredient](https://github.com/eprints/openoffice) to be installed along with a copy of OpenOffice or LibreOffice.


## Installation

1. Make sure the openoffice ingredient is already deployed following the installation instuctions for that ingredient.

2. Checkout this ingredient to your EPrints' ingredients directory.

3. Download the latest version [3.x version of Apache PDFBox](https://pdfbox.apache.org/download.html) as a standalone JAR file to the `bin/` directory of this ingredient.

4. From the `bin/' directory of this ingredient, create a symlink between this downloaded JAR file and its generic name used by `stitchPDFs` script in this ingredients. E.g.

```ln -s pdfbox-app-3.0.1.jar pdfbox-app.jar```

5. Add the ingredient to the inc file of the flavour used by your EPrints repository.  E.g. `EPRINTS\_PATH/flavours/pub\_lib/inc`

6. Run `epadmin update <ARCHIVE\_ID\> to update the EPrints database with the extra tables and columns needed for coversheets.

7. Run `epadmin test` to confirm there are no problems with your EPrints' overall configuration.

8. Reload your webserver. E.g. `apachectl graceful`


## Usage

'''TO BE WRITTEN'''


## Further Information

See https://wiki.eprints.org/w/Coversheets\_Ingredient
