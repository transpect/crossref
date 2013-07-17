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
    <xsl:variable name="key_ids" as="xs:string*"
      select="//crr:query[@status eq 'resolved'][crr:doi]/@key"/>
    <xsl:variable name="dois" as="xs:string*"
      select="//crr:query[@status eq 'resolved'][crr:doi]/crr:doi"/>
    <xsl:value-of select="'var arrHyperlinkIDs = ['"/>

    <!-- The key_ids must correspond to IDML’s HyperlinkTextDestination/@Name attributes 
    (without the leading 'HyperlinkTextDestination/') -->
    <xsl:sequence select="string-join(
                            for $id in $key_ids return
                              concat(
                                '&quot;', $id,
                                '&quot;'
                              ),
                            ','
                          )"/>

    <xsl:value-of select="'];&#xd;'"/>
    <xsl:value-of select="'var arrDOIs = ['"/>
    <xsl:for-each select="$dois">
      <xsl:value-of select="concat('&quot;', current(), '&quot;')"/>
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
</xsl:text>
  </xsl:template>

  <xsl:template name="javascript-end">
    <xsl:text>var myDoc = app.activeDocument,
    intHypIDlength = arrHyperlinkIDs.length,
    intNotFound = 0,
    arrNotFound = [];
if(app.documents.length != 0) {
  while( intHypIDlength-- ) {
    try{
      var myHyperlink = myDoc.hyperlinkTextDestinations.itemByName(arrHyperlinkIDs[intHypIDlength]),
        myPara = myHyperlink.destinationText.paragraphs[0].select(),
        intParaCharLength = myDoc.selection[0].contents.length;
			if (! myDoc.selection[0].contents.match(RegExp("DOI:"))) {
				myDoc.selection[0].paragraphs[0].insertionPoints[intParaCharLength - 1].select();
				myDoc.selection[0].contents = " DOI: " + arrDOIs[intHypIDlength]
				myHyperlinkURL = myDoc.hyperlinkURLDestinations.add("http://dx.doi.org/" +  arrDOIs[intHypIDlength]);
				myHyperlinkSource = myDoc.hyperlinkTextSources.add(
					myDoc.selection[0].paragraphs[0].characters.itemByRange(
						intParaCharLength + 5, 
						intParaCharLength + 4 + arrDOIs[intHypIDlength].length
					)
				);
				myHyperlink = myDoc.hyperlinks.add(myHyperlinkSource, myHyperlinkURL);
				myHyperlink.name = arrDOIs[intHypIDlength] + "_" + Math.random();
				myHyperlink.visible = true;
				myHyperlink.borderColor = UIColors.BLUE;
				myHyperlink.borderStyle = HyperlinkAppearanceStyle.SOLID;
				myHyperlink.highlight = HyperlinkAppearanceHighlight.OUTLINE;
			}
		} catch(e) {
		  intNotFound++;
		  arrNotFound.push( arrDOIs[intHypIDlength] + " " + arrHyperlinkIDs[intHypIDlength] );
	  }
  }
	if(intNotFound != 0) {
		alert("Fertig!\rEs wurden von " + arrHyperlinkIDs.length + " DOIs folgende " + intNotFound + " nicht hinzugefügt:\r\r" + arrNotFound.join("\r"), "DOI hinzufügen");
	} else {
		alert("Fertig!\rEs wurden " + arrHyperlinkIDs.length + " DOIs hinzugefügt.", "DOI hinzufügen");
	}
} else{
	alert("FEHLER: Es ist kein Dokument geöffnet!", "DOI hinzufügen");
}</xsl:text>
  </xsl:template>

  <!-- catch all -->

  <xsl:template match="node()|@*" mode="#all" priority="-1">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*"     mode="#current"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>