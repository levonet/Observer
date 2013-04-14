<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="html"/>
  <xsl:param name="locale">en</xsl:param>

  <xsl:template match="/help">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="title">
    <xsl:if test="lang($locale)">
      <h1><xsl:apply-templates /></h1><br/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="code">
    <pre><xsl:copy-of select="*|@*|text()" /></pre>
  </xsl:template>

  <xsl:template match="/help/constant/*|/help/constant/@*|/help/constant//text()">
    <xsl:copy>
      <xsl:apply-templates select="./*|./@*|.//text()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="content/*|content/@*|text()">
    <xsl:if test="lang($locale)">
      <xsl:copy>
        <xsl:apply-templates select="content/*|content/@*|text()" />
      </xsl:copy>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
