<?xml version='1.0' encoding='utf-8'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:variable name="newline" select="'&#xa;'" />
  <xsl:variable name="end_of_initializer" select="concat(',', $newline)" />
  <xsl:variable name="endif" select="concat('#endif', $newline)" />

  <xsl:template name="repeat">
    <xsl:param name="string" />
    <xsl:param name="times" />
    <xsl:if test="$times > 0">
      <xsl:value-of select="$string" />
      <xsl:call-template name="repeat">
	<xsl:with-param name="string" select="$string" />
	<xsl:with-param name="times" select="$times - 1" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="include">
    <xsl:param name="header" />
    <xsl:text>#include &lt;</xsl:text>
    <xsl:value-of select="$header" />
    <xsl:text>&gt;&#xa;</xsl:text>
  </xsl:template>

  <xsl:template name="ifdef">
    <xsl:param name="config" />
    <xsl:text>#ifdef </xsl:text>
    <xsl:value-of select="$config" />
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template name="initializer">
    <xsl:param name="indent_level" />
    <xsl:param name="member" />
    <xsl:call-template name="repeat">
      <xsl:with-param name="string">
	<xsl:text>&#x9;</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="times" select="$indent_level" />
    </xsl:call-template>
    <xsl:text>.</xsl:text>
    <xsl:value-of select="$member" />
    <xsl:text> = </xsl:text>
  </xsl:template>

</xsl:stylesheet>
