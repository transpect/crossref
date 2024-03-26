<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:crq="http://www.crossref.org/qschema/2.0"
  xmlns="http://www.crossref.org/qschema/2.0"
  exclude-result-prefixes="crq xs"
  version="2.0">
  
  <xsl:template name="main">
    <body>
      <xsl:apply-templates select="/*" mode="look-for-bib"/>  
    </body>
  </xsl:template>
  
  <xsl:template match="node()" mode="look-for-bib">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <!-- Query all citations that have an ID and that do not already have a DOI.
       There should be some Schematron running beforehand so that citations 
       without ID will be reported. -->
  <xsl:template match="ref[@id | mixed-citation/@id][not(*/pub-id[@pub-id-type eq 'doi'])]" mode="look-for-bib">
    <!-- specific-use carries the name of InDesign’s HypertextDestination. We need this (if available) for the 
      generated .jsx -->
    <xsl:variable name="key" as="xs:string?" select="(@specific-use, @id, mixed-citation/@id)[1]"/>
    <xsl:choose>
      <xsl:when test="not($key) or ($key = '')">
        <query key="generated_no-id_{generate-id()}" enable-multiple-hits="true" list-components="true" expanded-results="true">
          <xsl:apply-templates mode="transform-bib"/>  
        </query>
      </xsl:when>
      <xsl:otherwise>
        <query key="{substring($key, 1, 128)}" enable-multiple-hits="true">
          <xsl:apply-templates mode="transform-bib"/>  
        </query>  
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="mixed-citation" mode="transform-bib">
    <xsl:apply-templates select="source[1], person-group[@person-group-type = 'author'][1], volume[1], fpage[1], year[1], 
                                 pub-id[@pub-id-type = 'doi'][1], article-title[1]" mode="#current"/>
    <unstructured_citation>
      <xsl:value-of select="crq:normalize-space(.)"/>
<!--      <xsl:apply-templates mode="#current"/>-->
    </unstructured_citation>
  </xsl:template>
  
  <xsl:template match="article-title | chapter-title | volume | year" mode="transform-bib">
    <xsl:element name="{replace(name(), '-', '_')}">
      <xsl:value-of select="replace(crq:normalize-space(.), '(^[.,;]|[.,;]\s*$)', '')"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="fpage" mode="transform-bib">
    <xsl:if test="../@publication-type = ('journal', 'book_chapter')">
      <first_page>
        <xsl:value-of select="crq:normalize-space(.)"/>
      </first_page>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="person-group" mode="transform-bib">
    <xsl:apply-templates select="string-name[1]" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="pub-id[@pub-id-type = 'doi']" mode="transform-bib">
    <doi>
      <xsl:value-of select="crq:normalize-space(.)"/>
    </doi>
  </xsl:template>

  <xsl:template match="pub-id[@pub-id-type = 'doi'][string-length(.) lt 6]" 
    mode="transform-bib" priority="2">
    <xsl:message>DOI '<xsl:value-of select="."/>' too short in <xsl:value-of select="ancestor::mixed-citation/(@specific-use, @id)[1]"/></xsl:message>
  </xsl:template>
  

  <xsl:template match="string-name" mode="transform-bib">
    <xsl:element name="{../@person-group-type}">
      <xsl:value-of select="crq:normalize-space(.)"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="source" mode="transform-bib">
    <xsl:variable name="name" as="xs:string?">
      <xsl:choose>
        <xsl:when test="../@publication-type = 'journal'">
          <xsl:sequence select="'journal_title'"/>
        </xsl:when>
        <xsl:when test="../@publication-type = ('book', 'book_chapter')">
          <xsl:sequence select="'volume_title'"/>
        </xsl:when>
        <xsl:when test="../@publication-type = 'thesis'"/>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$name">
      <xsl:element name="{$name}">
        <xsl:variable name="normalize-space-etc" as="xs:string">
          <xsl:choose>
            <xsl:when test="$name = 'journal_title'">
              <!-- We found that out by chance… -->
              <xsl:sequence select="replace(crq:normalize-space(.), ':', '%3A')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="crq:normalize-space(.)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="replace($normalize-space-etc, '(^[.,;]|[.,;]\s*$)', '')"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>
  
  <!-- mixed citations that start with, e.g., 'DIN:' cause all queries in a batch to fail ("unable to parse query") -->
  <xsl:template match="text()[. is (ancestor::mixed-citation//text())[1]][matches(., '^[\w\p{Pd}]+\.')]" mode="transform-bib">
    <xsl:value-of select="replace(., '^([\w\p{Pd}]+)\.', '$1, Jj')"/>
  </xsl:template>
  
  <xsl:template match="text()" mode="transform-bib">
    <xsl:value-of select="replace(., '&#xad;', '')"/>
  </xsl:template>
  
  <!-- Apparently i and b will be discarded during resolution. So we’ll just
    dissolve them. -->
  <xsl:template match="italic" mode="transform-bib_DISABLED">
    <i>
      <xsl:apply-templates mode="#current"/>
    </i>
  </xsl:template>
  
  <xsl:template match="bold" mode="transform-bib_DISABLED">
    <b>
      <xsl:apply-templates mode="#current"/>
    </b>
  </xsl:template>
  
  <xsl:function name="crq:normalize-space" as="xs:string">
    <xsl:param name="input" as="xs:string"/>
    <xsl:sequence select="substring( 
			    normalize-space(
			                     replace(
                              replace(
                                  replace(
                                    $input, (: eliminating space around the dash in page number ranges :)
                                    '(\d+)[\s\p{Zs}]?(\p{Pd})[\s\p{Zs}]?(\d+)',
                                    '$1$2$3'
                                  ),
                                '[\p{Zs}\s]+', 
                                ' '
                              ),
                              '^\d+\.\p{Zs}+', (: eliminating number in Vancouver :)
                              '', 's')
                            ),
			    1,
			    256
			  )"/>
  </xsl:function>
  
</xsl:stylesheet>
