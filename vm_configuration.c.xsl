<?xml version='1.0' encoding='utf-8'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:include href="lib.xsl" />
  <xsl:output method="text" indent="yes"/>

  <xsl:template match="/acrn-config">
    <!-- Included headers -->
    <xsl:call-template name="include">
      <xsl:with-param name="header">vm_config.h</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="include">
      <xsl:with-param name="header">vuart.h</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="include">
      <xsl:with-param name="header">pci_dev.h</xsl:with-param>
    </xsl:call-template>
    <xsl:value-of select="$newline" />

    <!-- Declaration of pci_devs -->
    <xsl:for-each select="vm">
      <xsl:text>extern struct acrn_vm_pci_dev_config </xsl:text>
      <xsl:choose>
	<xsl:when test="vm_type = 'SOS_VM'">
	  <xsl:text>sos_pci_devs[CONFIG_MAX_PCI_DEV_NUM];</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:variable name="vm_id" select="string(position() - 1)" />
	  <xsl:value-of select="concat('vm', $vm_id, '_pci_devs[VM', $vm_id, '_CONFIG_PCI_DEV_NUM];')" />
	</xsl:otherwise>
      </xsl:choose>
      <xsl:text>&#xa;</xsl:text>
    </xsl:for-each>

    <xsl:value-of select="$newline" />
      <xsl:choose>
	<xsl:when test="@board = 'ehl-crb-b'">
    <xsl:variable name="pt_intx" select="pt_intx" />
      <xsl:choose>
    <xsl:when test="$pt_intx != ''">
      <xsl:value-of select="concat('extern struct pt_intx_config vm0_pt_intx[', $pt_intx, 'U];')" />
      </xsl:when>
    <xsl:otherwise>
      <xsl:text>extern struct pt_intx_config vm0_pt_intx[1U];</xsl:text>
    </xsl:otherwise>
      </xsl:choose>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>extern struct pt_intx_config vm0_pt_intx[1U];</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    <xsl:value-of select="$newline" />
    <xsl:value-of select="$newline" />

    <!-- Definition of vm_configs -->
    <xsl:text>struct acrn_vm_config vm_configs[CONFIG_MAX_VM_NUM] = {</xsl:text>
    <xsl:value-of select="$newline" />
    <xsl:apply-templates select="vm"/>
    <xsl:text>};</xsl:text>
    <xsl:value-of select="$newline" />
  </xsl:template>

  <xsl:template match="/acrn-config/vm">
    <!-- Initializer of a acrn_vm_configs instance -->
    <xsl:text>&#x9;{&#x9;/* VM</xsl:text>
    <xsl:value-of select="@id" />
    <xsl:text> */&#xa;</xsl:text>

    <xsl:apply-templates select="vm_type" />
    <xsl:apply-templates select="name" />
    <xsl:apply-templates select="guest_flags" />
    <xsl:apply-templates select="cpu_affinity" />
    <xsl:apply-templates select="clos" />
    <xsl:apply-templates select="epc_section" />
    <xsl:apply-templates select="memory" />
    <xsl:apply-templates select="os_config" />
    <xsl:call-template name="acpi_config" />
    <xsl:apply-templates select="legacy_vuart" />
    <xsl:call-template name="pci_dev_num" />
    <xsl:call-template name="pci_devs" />
    <xsl:call-template name="pre_lanched" />

    <!-- End of the initializer -->
    <xsl:text>&#x9;},&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="/acrn-config/vm/vm_type">
    <xsl:text>&#x9;&#x9;</xsl:text>
    <xsl:choose>
      <xsl:when test="current() = 'PRE_RT_VM'">CONFIG_PRE_RT_VM</xsl:when>
      <xsl:when test="current() = 'SAFETY_VM'">CONFIG_SAFETY_VM</xsl:when>
      <xsl:when test="current() = 'PRE_STD_VM'">CONFIG_PRE_STD_VM</xsl:when>
      <xsl:when test="current() = 'SOS_VM'">CONFIG_SOS_VM</xsl:when>
      <xsl:when test="current() = 'POST_STD_VM'">CONFIG_POST_STD_VM</xsl:when>
      <xsl:when test="current() = 'POST_RT_VM'">CONFIG_POST_RT_VM</xsl:when>
      <xsl:when test="current() = 'KATA_VM'">CONFIG_KATA_VM</xsl:when>
    </xsl:choose>
    <xsl:if test="current() != 'SOS_VM'">
      <xsl:text>(</xsl:text>
      <xsl:value-of select="count(../preceding-sibling::vm[vm_type=current()]) + 1" />
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:text>,&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="/acrn-config/vm/name">
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">2</xsl:with-param>
      <xsl:with-param name="member">name</xsl:with-param>
    </xsl:call-template>
    <xsl:value-of select="concat('&#x22;', current(), '&#x22;')" />
    <xsl:value-of select="$end_of_initializer" />
  </xsl:template>

  <xsl:template match="/acrn-config/vm/cpu_affinity">
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">2</xsl:with-param>
      <xsl:with-param name="member">cpu_affinity</xsl:with-param>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="../vm_type = 'SOS_VM'">
	<xsl:text>SOS_VM_CONFIG_CPU_AFFINITY</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="concat('VM', string(count(../preceding-sibling::vm)), '_CONFIG_CPU_AFFINITY')" />
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$end_of_initializer" />
  </xsl:template>

  <xsl:template match="/acrn-config/vm/guest_flags">
    <xsl:if test="((../vm_type = 'SOS_VM') or (../vm_type = 'PRE_RT_VM') or (../vm_type = 'PRE_STD_VM')) or (../vm_type = 'SAFETY_VM')">
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">2</xsl:with-param>
      <xsl:with-param name="member">guest_flags</xsl:with-param>
    </xsl:call-template>
    <xsl:for-each select="guest_flag">
      <xsl:if test="position() > 1">
	<xsl:text> | </xsl:text>
      </xsl:if>
      <xsl:value-of select="current()" />
    </xsl:for-each>
    <xsl:value-of select="$end_of_initializer" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="/acrn-config/vm/clos">
    <xsl:variable name="vm_id" select="string(position() - 1)" />
    <xsl:call-template name="ifdef">
      <xsl:with-param name="config">CONFIG_RDT_ENABLED</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">2</xsl:with-param>
      <xsl:with-param name="member">clos</xsl:with-param>
    </xsl:call-template>
	<xsl:value-of select="concat('VM', string(count(../preceding-sibling::vm)), '_VCPU_CLOS')" />
    <xsl:value-of select="$end_of_initializer" />
    <xsl:value-of select="$endif" />
  </xsl:template>

  <xsl:template match="/acrn-config/vm/memory">
    <xsl:text>&#x9;&#x9;.memory = {</xsl:text>
    <xsl:value-of select="$newline" />
    <xsl:variable name="vm_id" select="string(position() - 1)" />
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">3</xsl:with-param>
      <xsl:with-param name="member">start_hpa</xsl:with-param>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="../vm_type = 'SOS_VM'">
    <xsl:value-of select="start_hpa" />
    <xsl:text>UL</xsl:text>
      </xsl:when>
      <xsl:otherwise>
    <xsl:value-of select="concat('VM', $vm_id, '_CONFIG_MEM_START_HPA')" />
     </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$end_of_initializer" />
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">3</xsl:with-param>
      <xsl:with-param name="member">size</xsl:with-param>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="../vm_type = 'SOS_VM'">
    <xsl:text>CONFIG_SOS_RAM_SIZE</xsl:text>
      </xsl:when>
      <xsl:otherwise>
    <xsl:value-of select="concat('VM', $vm_id, '_CONFIG_MEM_SIZE')" />
     </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$end_of_initializer" />
     <xsl:if test="../vm_type != 'SOS_VM'">
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">3</xsl:with-param>
      <xsl:with-param name="member">start_hpa2</xsl:with-param>
    </xsl:call-template>
    <xsl:value-of select="concat('VM', $vm_id, '_CONFIG_MEM_START_HPA2')" />
    <xsl:value-of select="$end_of_initializer" />
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">3</xsl:with-param>
      <xsl:with-param name="member">size_hpa2</xsl:with-param>
    </xsl:call-template>
    <xsl:value-of select="concat('VM', $vm_id, '_CONFIG_MEM_SIZE_HPA2')" />
    <xsl:value-of select="$end_of_initializer" />
      </xsl:if>
    <xsl:text>&#x9;&#x9;},&#xa;</xsl:text>
  </xsl:template>

   <xsl:template match="/acrn-config/vm/epc_section">
    <xsl:variable name="base" select="base" />
    <xsl:variable name="size" select="size" />
    <xsl:if test="(($base != '0') and ($size != '0'))">
    <xsl:text>&#x9;&#x9;.epc = {</xsl:text>
    <xsl:value-of select="$newline" />
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">3</xsl:with-param>
      <xsl:with-param name="member">base</xsl:with-param>
    </xsl:call-template>
	  <xsl:value-of select="base" />
    <xsl:value-of select="$end_of_initializer" />
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">3</xsl:with-param>
      <xsl:with-param name="member">size</xsl:with-param>
    </xsl:call-template>
    <xsl:value-of select="size" />
    <xsl:value-of select="$end_of_initializer" />
    <xsl:text>&#x9;&#x9;},&#xa;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="/acrn-config/vm/os_config">
    <xsl:text>&#x9;&#x9;.os_config = {</xsl:text>
    <xsl:value-of select="$newline" />
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">3</xsl:with-param>
      <xsl:with-param name="member">name</xsl:with-param>
    </xsl:call-template>
    <xsl:value-of select="concat('&#x22;',name, '&#x22;')" />
    <xsl:value-of select="$end_of_initializer" />
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">3</xsl:with-param>
      <xsl:with-param name="member">kernel_type</xsl:with-param>
    </xsl:call-template>
    <xsl:value-of select="kern_type" />
    <xsl:value-of select="$end_of_initializer" />
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">3</xsl:with-param>
      <xsl:with-param name="member">kernel_mod_tag</xsl:with-param>
    </xsl:call-template>
    <xsl:value-of select="concat('&#x22;',kern_mod, '&#x22;')" />
    <xsl:value-of select="$end_of_initializer" />
    <xsl:variable name="kern_load_addr" select="kern_load_addr" />
    <xsl:if test="$kern_load_addr != ''">
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">3</xsl:with-param>
      <xsl:with-param name="member">kernel_load_addr</xsl:with-param>
    </xsl:call-template>
    <xsl:value-of select="kern_load_addr" />
    <xsl:value-of select="$end_of_initializer" />
    </xsl:if>
    <xsl:variable name="kern_entry_addr" select="kern_entry_addr" />
    <xsl:if test="$kern_entry_addr != ''">
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">3</xsl:with-param>
      <xsl:with-param name="member">kernel_entry_addr</xsl:with-param>
    </xsl:call-template>
    <xsl:value-of select="kern_entry_addr" />
    <xsl:value-of select="$end_of_initializer" />
    </xsl:if>
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">3</xsl:with-param>
      <xsl:with-param name="member">bootargs</xsl:with-param>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="../vm_type = 'SOS_VM'">
    <xsl:text>SOS_VM_BOOTARGS</xsl:text>
      </xsl:when>
      <xsl:otherwise>
    <xsl:variable name="vm_id" select="string(position() - 1)" />
	  <xsl:value-of select="concat('VM', $vm_id, '_BOOT_ARGS')" />
     </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$end_of_initializer" />
    <xsl:text>&#x9;&#x9;},&#xa;</xsl:text>
  </xsl:template>

  <xsl:template name="acpi_config">
    <xsl:if test="(vm_type = 'PRE_RT_VM') or (vm_type = 'SAFETY_VM')">
      <xsl:text>&#x9;&#x9;.acpi_config = {</xsl:text>
      <xsl:value-of select="$newline" />
      <xsl:call-template name="initializer">
        <xsl:with-param name="indent_level">3</xsl:with-param>
        <xsl:with-param name="member">acpi_mod_tag</xsl:with-param>
      </xsl:call-template>
      <xsl:variable name="vm_id" select="string(position() - 1)" />
      <xsl:value-of select="concat('&#x22;','ACPI_VM', $vm_id, '&#x22;')" />
      <xsl:value-of select="$end_of_initializer" />
      <xsl:text>&#x9;&#x9;},&#xa;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="/acrn-config/vm/legacy_vuart">
    <xsl:variable name="vuart_id" select="string(position() - 1)" />
    <xsl:text>&#x9;&#x9;.vuart[</xsl:text>
      <xsl:value-of select="$vuart_id" />
    <xsl:text>] = {</xsl:text>
    <xsl:value-of select="$newline" />
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">3</xsl:with-param>
      <xsl:with-param name="member">type</xsl:with-param>
    </xsl:call-template>
    <xsl:value-of select="type" />
    <xsl:value-of select="$end_of_initializer" />
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">3</xsl:with-param>
      <xsl:with-param name="member">addr.port_base</xsl:with-param>
    </xsl:call-template>
    <xsl:value-of select="base" />
    <xsl:value-of select="$end_of_initializer" />
    <xsl:variable name="base" select="base" />
    <xsl:if test="$base != 'INVALID_COM_BASE'">
      <xsl:call-template name="initializer">
        <xsl:with-param name="indent_level">3</xsl:with-param>
        <xsl:with-param name="member">irq</xsl:with-param>
      </xsl:call-template>
      <xsl:value-of select="irq" />
      <xsl:value-of select="$end_of_initializer" />
      <xsl:if test="$vuart_id = '1'">
        <xsl:call-template name="initializer">
          <xsl:with-param name="indent_level">3</xsl:with-param>
          <xsl:with-param name="member">t_vuart.vm_id</xsl:with-param>
        </xsl:call-template>
        <xsl:value-of select="target_vm_id" />
        <xsl:text>U</xsl:text>
        <xsl:value-of select="$end_of_initializer" />
        <xsl:call-template name="initializer">
          <xsl:with-param name="indent_level">3</xsl:with-param>
          <xsl:with-param name="member">t_vuart.vuart_id</xsl:with-param>
        </xsl:call-template>
        <xsl:value-of select="target_uart_id" />
        <xsl:text>U</xsl:text>
        <xsl:value-of select="$end_of_initializer" />
      </xsl:if>
    </xsl:if>
    <xsl:text>&#x9;&#x9;},&#xa;</xsl:text>
  </xsl:template>

  <xsl:template name="pci_dev_num">
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">2</xsl:with-param>
      <xsl:with-param name="member">pci_dev_num</xsl:with-param>
    </xsl:call-template>
  <xsl:variable name="vm_id" select="string(position() - 1)" />
	<xsl:value-of select="concat('VM', $vm_id, '_CONFIG_PCI_DEV_NUM')" />
    <xsl:value-of select="$end_of_initializer" />
  </xsl:template>

  <xsl:template name="pci_devs">
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">2</xsl:with-param>
      <xsl:with-param name="member">pci_devs</xsl:with-param>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="vm_type = 'SOS_VM'">
    <xsl:text>sos_pci_devs</xsl:text>
    <xsl:value-of select="$end_of_initializer" />
      </xsl:when>
      <xsl:otherwise>
    <xsl:variable name="vm_id" select="string(position() - 1)" />
    <xsl:value-of select="concat('vm', $vm_id, '_pci_devs')" />
    <xsl:value-of select="$end_of_initializer" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="pre_lanched">
    <xsl:if test="((vm_type = 'PRE_RT_VM') or (vm_type = 'PRE_STD_VM')  or (vm_type = 'SAFETY_VM'))">
      <xsl:call-template name="ifdef">
        <xsl:with-param name="config">VM0_PASSTHROUGH_TPM</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="initializer">
        <xsl:with-param name="indent_level">2</xsl:with-param>
        <xsl:with-param name="member">pt_tpm2</xsl:with-param>
      </xsl:call-template>
    	<xsl:text>true</xsl:text>
      <xsl:value-of select="$end_of_initializer" />
    <xsl:text>&#x9;&#x9;.mmiodevs[0] = {</xsl:text>
    <xsl:value-of select="$newline" />
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">3</xsl:with-param>
      <xsl:with-param name="member">base_gpa</xsl:with-param>
    </xsl:call-template>
      <xsl:text>VM0_TPM_BUFFER_BASE_ADDR_GPA</xsl:text>
    <xsl:value-of select="$end_of_initializer" />
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">3</xsl:with-param>
      <xsl:with-param name="member">base_hpa</xsl:with-param>
    </xsl:call-template>
      <xsl:text>VM0_TPM_BUFFER_BASE_ADDR</xsl:text>
    <xsl:value-of select="$end_of_initializer" />
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">3</xsl:with-param>
      <xsl:with-param name="member">size</xsl:with-param>
    </xsl:call-template>
    <xsl:text>VM0_TPM_BUFFER_SIZE</xsl:text>
    <xsl:value-of select="$end_of_initializer" />
    <xsl:text>&#x9;&#x9;},&#xa;</xsl:text>
    <xsl:value-of select="$endif" />
    <xsl:call-template name="ifdef">
        <xsl:with-param name="config">P2SB_BAR_ADDR</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="initializer">
        <xsl:with-param name="indent_level">2</xsl:with-param>
        <xsl:with-param name="member">pt_p2sb_bar</xsl:with-param>
      </xsl:call-template>
    	<xsl:text>true</xsl:text>
      <xsl:value-of select="$end_of_initializer" />
    <xsl:text>&#x9;&#x9;.mmiodevs[0] = {</xsl:text>
    <xsl:value-of select="$newline" />
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">3</xsl:with-param>
      <xsl:with-param name="member">base_gpa</xsl:with-param>
    </xsl:call-template>
      <xsl:text>P2SB_BAR_ADDR_GPA</xsl:text>
    <xsl:value-of select="$end_of_initializer" />
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">3</xsl:with-param>
      <xsl:with-param name="member">base_hpa</xsl:with-param>
    </xsl:call-template>
      <xsl:text>P2SB_BAR_ADDR</xsl:text>
    <xsl:value-of select="$end_of_initializer" />
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">3</xsl:with-param>
      <xsl:with-param name="member">size</xsl:with-param>
    </xsl:call-template>
    <xsl:text>P2SB_BAR_SIZE</xsl:text>
    <xsl:value-of select="$end_of_initializer" />
    <xsl:text>&#x9;&#x9;},&#xa;</xsl:text>
    <xsl:value-of select="$endif" />
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">2</xsl:with-param>
      <xsl:with-param name="member">pt_intx_num</xsl:with-param>
    </xsl:call-template>
    <xsl:text>VM0_PT_INTX_NUM</xsl:text>
    <xsl:value-of select="$end_of_initializer" />
    <xsl:call-template name="initializer">
      <xsl:with-param name="indent_level">2</xsl:with-param>
      <xsl:with-param name="member">pt_intx</xsl:with-param>
    </xsl:call-template>
    <xsl:text>&amp;vm0_pt_intx[0U]</xsl:text>
    <xsl:value-of select="$end_of_initializer" />
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
