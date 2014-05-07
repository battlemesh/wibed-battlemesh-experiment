#    Copyright (C) OpenWRT.org
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
#    The full GNU General Public License is included in this distribution in
#    the file called "COPYING".
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=wibed-battlemesh-experiment
PKG_RELEASE:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/wibed-wbm-exp
  SECTION:=net
  CATEGORY:=WBM
  TITLE:=Addons for wibed battlemesh experiment
  URL:=http://battlemesh.org
  DEPENDS:= \
	+ip +mtr +iputils-ping6 \
	+bmx6 +bmx6-uci-config +olsrd +kmod-batman-adv +babeld
endef

define Package/wbm-testbed/description
 Required addons for Wireless Battle of the Mesh WiBed experiment
endef

define Package/wbm-testbed/conffiles
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/wbm-testbed/install
	$(CP) ./files/* $(1)/
	chmod 755 $(1)/usr/bin/wbm-manage
	chmod 755 $(1)/etc/wbm/protos/*.sh
endef

$(eval $(call BuildPackage,wibed-wbm-exp))

