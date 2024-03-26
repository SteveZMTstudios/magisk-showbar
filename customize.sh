#!/system/bin/sh
MODDIR=${0%/*}
# 要预安装

# 如果你需要移除兼容性检查，移除此文件即可。
# !但这意味着您应当对刷入后产生的一切后果承担一切责任！
##################################
TargetCode="k80_bsp]"
DeviceCode=`
getprop | grep ro.build.product`

TargetBaseband="LEQIN_O1MP2_K80_BSP_HSPA_HW(DEFAULT)]"
TargetMtkVer="alps-mp-o1.mp2]"
DeviceMtkVer=`getprop | grep ro.mediatek.version.release`
DeviceBaseband=`getprop | grep gsm.project.baseband]`

TargetChip="MT6580]"
DeviceChip=`getprop | grep ro.mediatek.platform`
TargetAPI=27
isDisabled=0
disableCheck(){
    if [ $isDisabled -eq 0 ]
    then
        ui_print "√ 未发现异常"
        return 0
    else
        touch $MODPATH/disable
        ui_print "! 一个或多个兼容性检查未通过，为确保设备稳定，已将其禁用。"
        return 0
    fi
}
killInstall(){
    ui_print "############################"
    ui_print ""
    ui_print "× 一个或多个关键的安装出错，模块将不会被安装。请与模块开发者联系。"
    ui_print "- 酷安 @史蒂夫ZMT 制作"
    ui_print "############################"
    ui_print ""
    abort "× 模块未安装。"
}



if [ "$BOOTMODE" != "true" ]
then
    ui_print "! Should install this module at Magisk manager."
fi

ui_print "- 开始兼容性检查"
ui_print ""

if [ ${ARCH} != "arm" ]
then
    ui_print "! 不匹配：关键：架构不一致！"
    isDisabled=1
fi

if [ ${API} -eq ${TargetAPI} ] 
then
    ui_print "- 匹配：安卓版本"
    
else
    ui_print "! 不匹配:关键：安卓版本和预期的不一致！"
    ui_print "${API}"
    killInstall
fi
# skip #
: ' 
if test ${DeviceBaseband##*[} = ${TargetBaseband} 
then
    ui_print "- 匹配:主板id"
else
    ui_print "! 不匹配：主板id"
    ui_print "Target:${TargetBaseband}"
    ui_print "Detect:${DeviceBaseband}"
    isDisabled=1
fi

if test ${DeviceCode##*[} = ${TargetCode} 
then
    ui_print "- 匹配：设备代号"
else
    ui_print "! 不匹配：关键：设备代号"
    isDisabled=1
fi

if test ${DeviceMtkVer##*[} = ${TargetMtkVer} 
then
    ui_print "- 匹配:芯片组版本"
else
    ui_print "! 不匹配：关键：芯片组版本"
    
    ui_print "${DeviceChip##*[}"
    ui_print "${TargetChip}"
    killInstall
fi
if test ${DeviceChip##*[} = ${TargetChip}
then
    ui_print "- 匹配：芯片组"
else
    ui_print "! 不匹配：芯片组"
    killInstall

fi
# Debug option

# isDisabled=1

 ' 

disableCheck
###########################
# 兼容性检查结束
# 下面实现安装的操作

ui_print "- 开始安装"
ui_print "- 注意，不要使用任何工具提取此模块并分享给其他人！"
ui_print "  请始终分享模块原始安装包以确保安装程序可以动态配置。"
ui_print "- 检查系统是否支持"

if [ -d "/vendor/overlay" ];then
  ui_print "- 成功: 找到/vendor/overlay目录"
  else
  ui_print "! 失败: /vendor/overlay目录不存在！"
  ui_print "! ================================= !"
  ui_print "! 您的设备不支持通过撤销厂商的修改来启用状态栏。"
  ui_print "! 另请您不要试图直接创建文件夹来尝试启用状态栏，这不会起作用，而且可能使你的设备无法启动！"
  killInstall
  
fi
ui_print "- 正在复制文件以实现动态挂载... "

# mkdir $MODPATH/system/vendor/overlay
: ' 
if [ "$?" != "0" ]
then
    ui_print "! 创建目录时出现异常！正在重试..."
    mkdir $MODPATH/system/vendor/overlay
    ui_print "! 返回值${?}"
    ui_print "! 请检查设备指令集完整状态或截图联系开发者。"
    ui_print "! 联系开发者时请一并带上完整模块列表和机型信息 "
    killInstall
fi
'

cp -rf /vendor/overlay $MODPATH/system/vendor

if [ "$?" != "0" ]
then
    ui_print "! 复制文件时出现异常！正在重试..."
    cp -rf /vendor/overlay $MODPATH/system/vendor
    ui_print "! 返回值${?}"
    ui_print "! 请检查设备指令集完整状态或截图联系开发者。"
    ui_print "! 联系开发者时请一并带上完整模块列表和机型信息 "
    killInstall
fi

ui_print "- 检查文件... "
TargetFilePath=`find $MODPATH/system/vendor/overlay -iname "*framework-res*" `
TargetFile=${TargetFilePath##*/}
if [ -z "$TargetFilePath" ]
then
    ui_print "! 没找到文件！ "
    ui_print "! 可能是已经安装同类模块、不支持或者您的设备很新。 "
    ui_print "- 如果您是想要更新模块，那么您无需更新此模块"
    ui_print "  因为此次更新仅仅只是修改安装脚本，只要模块正常工作即可忽略此次更新。"
    ui_print "- 您的设备未被修改，请联系开发者寻求帮助。 "
    killInstall
    else
    ui_print "- 成功: 目标目录:${TargetFilePath} "
fi
ui_print "- 准备挂载替换... "
ui_print "${TargetFilePath} will be removed."
rm $TargetFilePath
if [ "$?" != "0" ]
then
    ui_print "! 错误：挂载删除时失败！ "
    killInstall
    else
    ui_print "- 成功: 已挂载替换 "
fi


REPLACE="
/system/vendor/overlay
"

# 结束
###########################


ui_print "√ 安装完成！"
ui_print "- 已建立简易救砖脚本，当卡开机时自动停用模块。 "
ui_print "√ 酷安 @史蒂夫ZMT 制作，感谢_Forward_提供的方案！"

# 发现彩蛋！
# 此模块是在单词笔上编辑并测试的！
# 此文档累计贡献16根头发
