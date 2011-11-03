# This Makefile controls leto.net
# Currently just generates spiffy adsense-optimized image pages 
# Bow to me, fleshy mortals...

### Important directories 
BASE_DIR=/export/domains/leto.net
WWW=${BASE_DIR}/htdocs
CONTROL_DIR=${BASE_DIR}/control
LOG_DIR=${BASE_DIR}/logs
CONTENT_DIR=${WWW}/content
IMAGES_DIR=${WWW}/pics
TEMPLATE_DIR=${WWW}/templates

## FILES
TOP=${CONTENT_DIR}/top.php
HEAD=${CONTENT_DIR}/head.php
FOOT=${CONTENT_DIR}/foot.php
LOGOSEARCH=${CONTENT_DIR}/logosearch.php
LEFTAD=${CONTENT_DIR}/leftad.php
RIGHTAD=${CONTENT_DIR}/rightad.php
TMPL=${TEMPLATE_DIR}/template.php

ECUADOR2006=${IMAGES_DIR}/2006/ecuador


imagebot=${CONTROL_DIR}/bin/imagebot

begin:
	@echo This is where it all begins

pics: pics_ecuador_2006 pics_august_2007 pics_sanfordzoo_2007 pics_november_2006 pics_myco

pics_ecuador_2006:	begin
	${imagebot} /pics/2006/ecuador
	ln -sf ${WWW}/pics/2006/ecuador/page1.php ${WWW}/pics/2006/ecuador/index.php

pics_sanfordzoo_2007: begin
	${imagebot} /pics/2007/sanfordzoo
	ln -sf ${WWW}/pics/2007/sanfordzoo/page1.php ${WWW}/pics/2007/sanfordzoo/index.php
	
pics_august_2007:	begin
	${imagebot} /pics/2007/august
	ln -sf ${WWW}/pics/2007/august/page1.php ${WWW}/pics/2007/august/index.php
pics_november_2006:	begin
	${imagebot} /pics/2006/november
	ln -sf ${WWW}/pics/2006/november/page1.php ${WWW}/pics/2006/november/index.php

pics_myco:	begin
	${imagebot} /pics/myco
	ln -sf ${WWW}/pics/myco/page1.php ${WWW}/pics/myco/index.php
