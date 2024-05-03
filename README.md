# Coversheets

This is an ingredient intended for use with [EPrints 3.4](https://github.com/eprints/eprints3.4)+. It is designed to add branded coversheets to PDF documents uploaded to an archive.  It allows coversheet templates design in OpenOffice or LibreOffice to be uploaded and then allows you to choose to which eprint records these coversheet templates should be applied to generated coversheeted version of PDF documents uploaded for those eprint records.

This ingredient is based on the original [Coversheets Bazaar plugin](https://bazaar.eprints.org/350/).  There are many improvements to this Bazaar plugin but the main difference is that it no longer uses EPrints' indexer but is instead must be run as a cron job. This allows for better management of when coversheeting tasks run and also helps keep the indexer log clean.  As a lot of the noise can be generated from coversheeting, particularly when parsing PDF documents.

This ingredient also requires the [openoffice ingredient](https://github.com/eprints/openoffice) to be installed along with a copy of OpenOffice or LibreOffice.


## Installation

1. Make sure the [openoffice ingredient](https://github.com/eprints/openoffice) is already installed, following the installation instructions for that ingredient.

2. Clone this ingredient to EPrints' `ingredients/` directory on your server

3. Download the latest 3.x version of [Apache PDFBox](https://pdfbox.apache.org/download.html) as a standalone JAR file to the `bin/` directory of this ingredient on your server.

4. From the `bin/` directory of this ingredient on your server, create a symlink between this downloaded JAR file and its generic name used by the `stitchPDFs` script in this ingredient. E.g. `ln -s pdfbox-app-3.0.1.jar pdfbox-app.jar`

5. Add this ingredient to the inc file of the flavour used by your EPrints archive.  E.g. `EPRINTS_PATH/flavours/pub_lib/inc`

6. Run `epadmin update <ARCHIVE_ID>` to update the EPrints database with the extra tables and columns needed for coversheets.

7. Run `epadmin test` to confirm there are no problems with EPrints' overall configuration.

8. Reload the webserver. E.g. `apachectl graceful`


## Usage

This section describes how to use the script in the `bin/` directory of the coverhseets ingredient. 

### Update Coversheets

This is the script below will check a specified number (i.e. `LIMIT`) of eprint records in your archive (i.e. `ARCHIVE_ID` that have their `coversheets_dirty` field set to `TRUE` because relevant metadata has been changed in those eprint records that requires the associated PDF documents to have their coversheeted versions updated because their coversheet information is no longer up to date.
```
bin/check_coversheets <ARCHIVE_ID> <LIMIT>
```

#### As a Cron Job 
Typically you would want to run this as the `eprints` user as a regular cron job.  The following is a typical cron job you would want to add to the `eprints` user's crontab. (It is assumed EPrints is installed under the path `/opt/eprints3`):

```
*/15 * * * * /opt/eprints3/ingredients/coversheets/bin/check_coversheets_cron my_archive 50 3600 2>&1 | grep -v -f /opt/eprints3/ingredients/coversheets/bin/ignore_warnings.txt
```
This uses an envelope script for `check_coversheets` called `check_coversheets_cron` to make sure that multiple instances are not being run by cron at the same time. The `3600` specifies how many seconds to wait until it assumes that a previous run of `check_coversheets_cron` has died without completing.  If this is not specified it will assume 7200 seconds (2 hours). The above cron job will try to coversheet the PDF documents for up to 50 eprints every 15 minutes.  This is a conservative estimate of how long this will take to complete.  Having the protection of `check_coversheets_cron` means 15 could probably be reduced to 5 or fewer minutes.  The `grep` command after the script is intended to remove arbitrary noise generated by Apache PDFBox, as PDFs often have syntax issues which produce warning messages but these can typically be ignored rather than generate emails to the eprints' user's inbox.

#### Temporarily Disable Cron Job
If you need to make some changes to your EPrints repository codebase or configuration and don't want cron job to run for a while, rather than disabling the cron job (and potentially forgetting to re-enable it), you can use the following command to disable the cron job for a set amount of time:
```
bin/disable_coversheets <ARCHIVE_ID> <SECONDS>
```
E.g. 
```
bin/disable_coversheets my_archive 3600
```

#### For Specific EPrint records
If there is a specific eprint record for which you want to update its PDF documents, then you can use a slightly modified version of the `check_coversheets` command:

```
bin/check_coversheets <ARCHIVE_ID> <LIMIT> [--eprintid=EPRINT_ID]
```
Let us say you want to update coversheets for eprint with ID 1234 for your archived called `my_archive`, then command would be:

```
bin/check_coversheets my_archive 1 --eprintid=1234
```


### Add Coversheets to Specific Documents

Generally, you should use the `check_coversheets` script to just update all PDF documents for a specific eprint but if you have some reason you only want to update a particular PDF document you can use the following command:
```
bin/add_coversheet <ARCHIVE_ID> <DOCUMENT_ID>
```
This will use the specific coversheet template whose criteria is applicable to the document's associated eprint record.  


### Remove Coversheets 

You might decide that you no longer want to use coversheets and want to remove all coversheeted PDFs to save disk space.  You can use this command to remove all of these coversheeted PDF files:
```
bin/delete_coversheets <ARCHIVE_ID>
```
Alternatively, if some EPrints no longer need coversheets due to a change in the criteria for a coversheet template and these do not get tidied up in good time automatically, thenyou can removed coversheets from the documents of one of more individual eprint records. (Make sure there are no spaces between each eprint ID).  E.g. 
```
bin/delete_coversheets my_archive 1,2,3,4
```


### Update Coversheet-related Metadata
If you have only just started using coversheets then updating coversheet-related metadata should not be necessary.  However, if you were using an old version of coversheets, such as the on available in the [EPrints Bazaar](https://bazaar.eprints.org/350/), then you will want to run the following command to make sure all the metadata is in the correct format:
```
bin/update_coversheet_data <ARCHIVE_ID>
```


## Further Information

See https://wiki.eprints.org/w/Coversheets_Ingredient
