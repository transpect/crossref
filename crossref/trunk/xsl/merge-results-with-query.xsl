<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:crq="http://www.crossref.org/qschema/2.0"
  xmlns:crqr="http://www.crossref.org/qrschema/2.0"
  exclude-result-prefixes="xs crq"
  version="2.0">
  
  <!-- See the comments in ../xpl/merge-results-with-query.xpl
       If no collection()[2] document is supplied, then the query body document
       must be present below $s9y1-path, with a file name as constructed below. -->
  
  <xsl:key name="unstructured" match="crq:query[@key][crq:unstructured_citation]" use="@key"/>
  
  <xsl:param name="s9y1-path" as="xs:string?"/>
  <xsl:param name="basename" as="xs:string?"/>
  
<!--  <xsl:variable name="_query-body" as="document-node(element(crq:query_batch))"
    select="if (collection()[2])
            then collection()[2]
            else document(
                   resolve-uri(
                     concat(
                       'crossref/',
                       $basename,
                       '.qb.xml'
                     ),
                     $s9y1-path
                   )
                 )"/>-->

  <xsl:variable name="query-body" as="document-node(element(crq:query_batch))">
    <xsl:document><crq:query_batch/></xsl:document>
</xsl:variable>
  
  <xsl:template match="/" mode="#default">
<xsl:message select="'DDDDDDDDDDDDDDDDDD ', 
                     concat(
                       'crossref/',
                       $basename,
                       '.qb.xml'
                     ),
                     $s9y1-path
                   "/>
    <xsl:variable name="merge">
      <xsl:apply-templates select="*" mode="merge"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="collection()[2]">
        <xsl:sequence select="$merge"/>
      </xsl:when>
      <xsl:when test="not($s9y1-path) and not($basename)">
        <xsl:message terminate="yes">If no work-path and no work-basename are given, there must be a second document with the
          query body in the default collection.</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:result-document href="{resolve-uri(concat('crossref/', $basename, '.crossref.xml'), $s9y1-path)}">
          <xsl:sequence select="$merge"/>
        </xsl:result-document>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="* | @*" mode="merge">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/*" mode="merge">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:variable name="multi-groups" as="xs:integer"
        select="count(distinct-values(crqr:query_result/crqr:body/crqr:query[@status eq 'multiresolved']/@key))"/>
      <xsl:variable name="duplicates" as="xs:integer"
        select="count(crqr:query_result/crqr:body/crqr:query[@status eq 'multiresolved']) - $multi-groups"/>
      <xsl:comment>
Stats:
                  total: <xsl:value-of select="count(crqr:query_result/crqr:body/crqr:query) - $duplicates"/>
   without ID in source: <xsl:value-of select="count(crqr:query_result/crqr:body/crqr:query[starts-with(@key, 'generated_no-id_')]/@status[. eq 'unresolved'])"/>
      uniquely resolved: <xsl:value-of select="count(crqr:query_result/crqr:body/crqr:query/@status[. eq 'resolved'])"/>
          multiresolved: <xsl:value-of select="$multi-groups"/> (<xsl:value-of select="$duplicates"/> DOIs will be ignored in favor of the first DOI that was returned for each key)
  completely unresolved: <xsl:value-of select="count(crqr:query_result/crqr:body/crqr:query/@status[. eq 'unresolved'][../crqr:msg])"/>
              malformed: <xsl:value-of select="count(crqr:query_result/crqr:body/crqr:query/@status[. eq 'malformed'])"/> (usually theses or proceedings) 
   unresolved with tags: <xsl:value-of select="count(crqr:query_result/crqr:body/crqr:query/@status[. eq 'unresolved'][not(../crqr:msg)])"/>
                   none: <xsl:value-of select="count(crqr:query_result/crqr:body/crqr:query/@status[. eq 'none'])"/>
  <xsl:text>&#xa;</xsl:text>
              </xsl:comment>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="crqr:query[@key][not(crqr:unstructured_citation)]" mode="merge">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of copy-namespaces="no" select="@*, node()"/>
      <xsl:text xml:space="preserve">  </xsl:text>
      <xsl:apply-templates select="key('unstructured', @key, $query-body)/*:unstructured_citation" mode="as-comment"/>
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
