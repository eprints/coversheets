# Coversheets

This is an ingredient intended for use with EPrints 3.4+. It is designed to add branded coversheets to PDF documents uploaded to an archive.  It allows coversheet templates to be uploaded and then allows you to choose to which eprint records these coversheets should be applied.

This ingredient is based on the [original Coversheets Bazaar plugin](https://bazaar.eprints.org/350/).  There are many improvements to this Bazaar plugin but the main difference is that it no longer uses EPrints' indexer but is instead can be run periodically from a cron job. This allows for better management of when coversheeting tasks run and also helps keep the indexer log clean.  A lot of the noise can be generated from coversheeting, particularly when parsing PDF documents.

This ingredients also requires the [openoffice ingredient](https://github.com/eprints/openoffice) to be installed along with a copy of OpenOffice or LibreOffice.


## Installation

1. Make sure the [openoffice ingredient](https://github.com/eprints/openoffice) is already installed, following the installation instructions for that ingredient.

2. Checkout this ingredient to EPrints' `ingredients/` directory.

3. Download the latest 3.x version of [Apache PDFBox](https://pdfbox.apache.org/download.html) as a standalone JAR file to the `bin/` directory of this ingredient.

4. From the `bin/` directory of this ingredient, create a symlink between this downloaded JAR file and its generic name used by the `stitchPDFs` script in this ingredients. E.g. `ln -s pdfbox-app-3.0.1.jar pdfbox-app.jar`

5. Add this ingredient to the inc file of the flavour used by your EPrints archive.  E.g. `EPRINTS\_PATH/flavours/pub\_lib/inc`

6. Run `epadmin update <ARCHIVE\_ID\> to update the EPrints database with the extra tables and columns needed for coversheets.

7. Run `epadmin test` to confirm there are no problems with EPrints' overall configuration.

8. Reload the webserver. E.g. `apachectl graceful`


## Usage

***TO BE WRITTEN***


## Further Information

See https://wiki.eprints.org/w/Coversheets\_Ingredient
