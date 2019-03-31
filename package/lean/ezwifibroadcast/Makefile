include $(TOPDIR)/rules.mk

PKG_NAME:=ezwifibroadcast
PKG_RELEASE:=1.6R6

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/rodizio1/EZ-WifiBroadcast.git
PKG_SOURCE_DATE:=2018-10-16
PKG_SOURCE_VERSION:=2db9e268a69f86580a1a370678fee67544e836b1

PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/ezwifibroadcast
  SECTION:=net
  CATEGORY:=Network
  TITLE:=ezwifibroadcast
  DEPENDS:=+librt +libpcap +coreutils-stty +luci-mod-rpc +kmod-usb-serial-ch341
endef

define Package/ezwifibroadcast/description
 ezwifibroadcast on openwrt
endef

define Build/Configure
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)
	[ -d $(PKG_BUILD_DIR)/root ] && $(CP) $(PKG_BUILD_DIR)/root/wifibroadcast/* $(PKG_BUILD_DIR)/ || echo
	[ -d $(PKG_BUILD_DIR)/root ] && rm -rf $(PKG_BUILD_DIR)/root || echo
	[ -d $(PKG_BUILD_DIR)/boot ] && rm -rf $(PKG_BUILD_DIR)/boot || echo
	[ -f $(PKG_BUILD_DIR)/Makefile ] && rm $(PKG_BUILD_DIR)/Makefile || echo
	[ -f $(PKG_BUILD_DIR)/*.o ] && rm $(PKG_BUILD_DIR)/*.o || echo
	$(call Build/Configure/Default)
endef

define Package/ezwifibroadcast/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rx $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rx_rc_telemetry $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rx_rc_telemetry_buf $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rssirx $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rssitx $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tx_rawsock $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tx_telemetry $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tx_measure $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rx_status $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rssilogger $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/syslogger $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/channelscan $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/check_alive $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rssi_forward $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wifiscan $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wifibackgroundscan $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sharedmem_init_rx $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sharedmem_init_tx $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ftee $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ezwifibroadcast.init $(1)/etc/init.d/ezwifibroadcast
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/ezwifibroadcast.defaults $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_BIN) ./files/ezwifibroadcast.config $(1)/etc/config/wbc
endef

$(eval $(call BuildPackage,ezwifibroadcast))
