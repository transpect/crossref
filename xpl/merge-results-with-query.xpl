<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:crq="http://www.crossref.org/qschema/2.0"
  xmlns:crqr="http://www.crossref.org/qrschema/2.0"
  xmlns:jats="http://jats.nlm.nih.gov"
  version="1.0"
  name="merge-results-with-query"
  type="crq:merge-results-with-query">
  
  <p:input port="source" primary="true">
    <p:documentation>CrossRef query results</p:documentation>
  </p:input>
  <p:input port="qb">
    <p:documentation>The query body that was posted before the results were received</p:documentation>
  </p:input>
  <p:output port="result" primary="true">
    <p:documentation>The results with the initial unstructured_citations</p:documentation>
  </p:output>
  
  <p:xslt name="merge" initial-mode="merge">
    <p:input port="parameters"><p:empty/></p:input>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0">
          <xsl:key name="unstructured" match="crq:query[@key][crq:unstructured_citation]" use="@key"/>
          <xsl:template match="* | @*" mode="merge">
            <xsl:copy copy-namespaces="no">
              <xsl:apply-templates select="@*, node()" mode="#current"/>
            </xsl:copy>
          </xsl:template>
          <xsl:template match="/*" mode="merge">
            <xsl:copy copy-namespaces="no">
              <xsl:apply-templates select="@*" mode="#current"/>
              <xsl:comment>
Stats:
                  total: <xsl:value-of select="count(crqr:query_result/crqr:body/crqr:query)"/>
               resolved: <xsl:value-of select="count(crqr:query_result/crqr:body/crqr:query/@status[. eq 'resolved'])"/>
  completely unresolved: <xsl:value-of select="count(crqr:query_result/crqr:body/crqr:query/@status[. eq 'unresolved'][../crqr:msg])"/>
   unresolved with tags: <xsl:value-of select="count(crqr:query_result/crqr:body/crqr:query/@status[. eq 'unresolved'][not(../crqr:msg)])"/>
  <xsl:text>&#xa;</xsl:text>
              </xsl:comment>
              <xsl:apply-templates select="node()" mode="#current"/>
            </xsl:copy>
          </xsl:template>
          <xsl:template match="crqr:query[@key][not(crqr:unstructured_citation)]" mode="merge">
            <xsl:copy copy-namespaces="no">
              <xsl:copy-of copy-namespaces="no" select="@*, node()"/>
              <xsl:text xml:space="preserve">  </xsl:text>
              <xsl:apply-templates select="key('unstructured', @key, collection()[2])/*:unstructured_citation" mode="as-comment"/>
              <xsl:copy-of select="text()[last()]"/>
            </xsl:copy>
          </xsl:template>
          <xsl:template match="crqr:msg" mode="merge"/>
          <xsl:template match="crqr:unstructured_citation" mode="merge">
            <xsl:apply-templates select="." mode="as-comment"/>
          </xsl:template>
          <xsl:template match="*" mode="as-comment">
            <xsl:comment>
              <xsl:value-of select="."/>
            </xsl:comment>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
    <p:input port="source">
      <p:pipe port="source" step="merge-results-with-query"/>
      <p:pipe port="qb" step="merge-results-with-query"/>
    </p:input>
  </p:xslt>
  
</p:declare-step>