<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:crr="http://www.crossref.org/qrschema/2.0"
  exclude-result-prefixes="xs"
  version="2.0">

  <!-- 
       build-crossref-doi-javascript.xsl
       written by Philipp Glatza, le-tex publishing services GmbH, 2013

       sample invocation:
       saxon -xsl:build-crossref-doi-javascript.xsl -s:101026_sample_TP.crossref-result.xml -o:add-doi.jsx
  -->

  <xsl:output
    method="text"
    encoding="utf-8"
    />

  <xsl:template match="/" mode="foo">
    <foo>
      <xsl:apply-templates select="." mode="#default"/>
    </foo>
  </xsl:template>

  <xsl:template match="/">
    <xsl:call-template name="javascript-begin"/>
    
    <xsl:variable name="resolved-queries" as="element(crr:query)*">
      <xsl:for-each-group select="//crr:query[@status = ('multiresolved', 'resolved')][crr:doi]" group-by="@key">
        <!-- first doi in group if multiresolved -->  
        <xsl:sequence select="."/>
      </xsl:for-each-group>  
    </xsl:variable>
    
    <xsl:value-of select="'var arrHyperlinkIDs = ['"/>
    
    <!-- The keys must correspond to IDML’s HyperlinkTextDestination/@Name attributes 
    (without the leading 'HyperlinkTextDestination/') -->
    <xsl:sequence select="string-join(
                            for $id in $resolved-queries/@key return
                              concat(
                                '&quot;', $id,
                                '&quot;'
                              ),
                            ','
                          )"/>

    <xsl:value-of select="'];&#xd;'"/>
    <xsl:value-of select="'var arrDOIs = ['"/>
    <xsl:for-each select="$resolved-queries/crr:doi">
      <xsl:value-of select="concat('&quot;', ., '&quot;')"/>
      <xsl:if test="position() != last()">
        <xsl:value-of select="','"/>
      </xsl:if>
    </xsl:for-each>
    <xsl:value-of select="'];&#xd;'"/>
    <xsl:call-template name="javascript-end"/>
  </xsl:template>

  <xsl:template name="javascript-begin">
    <xsl:text>#target indesign
app.scriptPreferences.userInteractionLevel = UserInteractionLevels.interactWithAll;
var myLinkCharStyleName = "ch_xref_doi";
var myDOIurl = "https://doi.org/";
</xsl:text>
  </xsl:template>

  <xsl:template name="javascript-end">
    <xsl:text>if(app.documents.length != 0) {
	var myDoc = app.activeDocument,
    intHypIDlength = arrHyperlinkIDs.length,
    intNotFound = 0,
    arrNotFound = [];
	var myLinkCharStyle = getCharacterStyle(myLinkCharStyleName, myDoc); // ==>
	if(myLinkCharStyle) {
		var myCRSs = myDoc.crossReferenceSources,
				myCRSs_counter = myCRSs.length;
		while(myCRSs_counter--) {
			// cleanup: delete source texts in current p_ref paragraph (see https://redmine.le-tex.de/issues/6663#note-24)
			if(myCRSs[myCRSs_counter].sourceText.appliedParagraphStyle.name.match("^p_ref"))
				{myCRSs[myCRSs_counter].remove()}
		}
		while( intHypIDlength-- ) {
			try{
				var myHyperlink = myDoc.hyperlinkTextDestinations.itemByName(arrHyperlinkIDs[intHypIDlength]),
					myDOIstring = myDOIurl + arrDOIs[intHypIDlength],
					myPara = myHyperlink.destinationText.paragraphs[0].select(),
					intParaCharLength = myDoc.selection[0].contents.length,
					lastParaDOIchars = myDoc.selection[0].paragraphs[0].characters.itemByRange(
							intParaCharLength - 1 ,
							intParaCharLength - 1 - arrDOIs[intHypIDlength].length - myDOIurl.length 
						).contents.toString().replace(/.$/, '');
				var myDOIstringIsPresentAndUnlinked = myDOIstring.localeCompare(lastParaDOIchars) == 0 &amp;&amp; myDoc.selection[0].paragraphs[0].findHyperlinks().length == 0;
				if ((! myDoc.selection[0].contents.match(RegExp(myDOIurl))) || myDOIstringIsPresentAndUnlinked) {
					myDoc.selection[0].paragraphs[0].insertionPoints[intParaCharLength - 1].select();
					if(!myDOIstringIsPresentAndUnlinked) {myDoc.selection[0].contents = " " + myDOIstring;}
					try{
						var myHyperlinkURL = myDoc.hyperlinkURLDestinations.add(myDOIstring, {name: myDOIstring} );
					}
					catch(f) {
						var myHyperlinkURL = myDoc.hyperlinkURLDestinations.item(myDOIstring);
					}
					var mySel = (myDOIstringIsPresentAndUnlinked)?myDoc.selection[0].paragraphs[0].characters.itemByRange(intParaCharLength - arrDOIs[intHypIDlength].length - myDOIurl.length - 1, intParaCharLength - 2):myDoc.selection[0].paragraphs[0].characters.itemByRange(intParaCharLength,  intParaCharLength + myDOIurl.length - 1 + arrDOIs[intHypIDlength].length);                    
					mySel.applyCharacterStyle(myLinkCharStyle);
					myHyperlinkSource = myDoc.hyperlinkTextSources.add(mySel);
					myHyperlink = myDoc.hyperlinks.add(myHyperlinkSource, myHyperlinkURL);
					myHyperlink.name = arrDOIs[intHypIDlength] + "_" + Math.random();
					myHyperlink.visible = false;
					//myHyperlink.borderColor = UIColors.BLUE;
					//myHyperlink.borderStyle = HyperlinkAppearanceStyle.SOLID;
					//myHyperlink.highlight = HyperlinkAppearanceHighlight.OUTLINE;
				}
			} catch(e) {
				intNotFound++;
				arrNotFound.push( arrDOIs[intHypIDlength] + " " + arrHyperlinkIDs[intHypIDlength] );
			}
			myDoc.select(NothingEnum.NOTHING);
		}
		if(intNotFound != 0) {
			alert("Fertig!\rEs wurden von " + arrHyperlinkIDs.length + " DOIs folgende " + intNotFound + " nicht hinzugefügt:\r\r" + arrNotFound.join("\r"), "DOI hinzufügen");
		} else {
			alert("Fertig!\rEs wurden " + arrHyperlinkIDs.length + " DOIs hinzugefügt.", "DOI hinzufügen");
		}
	}
	else alert("FEHLER!\r\rDas Zeichenformat \"" + myLinkCharStyleName + "\" ist nicht angelegt."); 
} else{
	alert("FEHLER!\r\rEs ist kein Dokument geöffnet!", "DOI hinzufügen");
}

function getCharacterStyle (_name, _dok) {
	for (var i = 0; i &lt; _dok.allCharacterStyles.length; i++) {
		if (_dok.allCharacterStyles[i].name == _name ) return _dok.allCharacterStyles[i];
	}
	return null;
}</xsl:text>
  </xsl:template>

  <!-- catch all -->

  <xsl:template match="*|@*" mode="#all" priority="-1">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*"     mode="#current"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>