#!/bin/bash

echo Compilation started...
# Script is expected to start running in the folder where it is located (together with the source files)
SOURCE="$PWD"
# There is only one disclaimer and style docx file for all FIX Technical Standards and it is stored with the FIX Session Layer
# Repository has local copies with the specific names and dates of the standard
DISCLAIMER="FIXDisclaimerTechStd.md"
STYLE="FIX_TechStd_Style_MASTER.docx"
TARGET="$SOURCE/target"
YAML="$SOURCE/JSON.yaml"
FILES="Encoding_FIX_using_JSON-User_Guide.md"
WPFOLDER="/wp-content/uploads/2020/04/"

# Create document version with disclaimer
pandoc "$DISCLAIMER" $FILES -o "$TARGET/docx/Encoding_FIX_using_JSON RC1.docx" --reference-doc="$STYLE" --metadata-file="$YAML" --toc --toc-depth=4
echo JSON document version created

# Create base online version without disclaimer
pandoc $FILES -o "$TARGET/debug/JSONONLINE.html" -s --metadata-file="$YAML" --toc --toc-depth=2

# Create separate online versions for production and test website by including appropriate link prefixes
sed 's,img src="media/,img src="https://www.fixtrading.org'$WPFOLDER',g' "$TARGET/debug/JSONONLINE.html" > "$TARGET/html/JSONONLINE_PROD.html"
sed s/www.fixtrading.org/www.technical-fixprotocol.org/ "$TARGET/html/JSONONLINE_PROD.html" > "$TARGET/html/JSONONLINE_TEST.html"
echo JSON ONLINE version created for PROD and TEST

echo Compilation ended!
