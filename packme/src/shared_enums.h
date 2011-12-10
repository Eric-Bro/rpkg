//
//  shared_enums.h
//  

#ifndef shared_enums_h
  #define shared_enums_h

#define kDefaultChmodUtility @"/bin/chmod"
/*!
 * @Description:
 * 0 = user will can't select "items" for installation in a package ("Customize" menu is disabed), so 
 *     install only items marked as "starts_selected=true";
 * 1 = "Customize" menu is always must be shown;
 * 2 = user can check\uncheck items for installing or just
 *     select the "Standard Installation" (so democracy way :)) 
 */
enum EBPackageUIMode{
    kPackageUIModeEasy   = 0,
    kPackageUIModeCustom = 1,
    kPackageUIModeBoth   = 2
}EBPackageUIMode;

/*!
 * @Note: this values may be changed by time. For ex, in some 10.x.y 
 *        update Apple may say: " < 10.6.0 sucks!" and adds to this list the 10.6 value (and remove the 10.3, may be);
 */
enum EBPackageMinimumRequiredOS{
    kPackageMinimumRequired103 = 1,
    kPackageMinimumRequired104 = 2,
    kPackageMinimumRequired105 = 3
}EBPackageMinimumRequiredOS;

/*!
 * @Description: flags, responsible for a place where a package can be installed
 * Anywhere - in any partition which user will be selected;
 * System   - in the system partition only (if used with Anywhere flag - last just ignored);
 * User     - in the user's home dir;
 */
enum EBPackageDomainFlag{
    kPackageDomainAnywhereFlag = 0x1,
    kPackageDomainSystemFlag   = 0x2,
    kPackageDomainUserFlag     = 0x4
}EBPackageDomainFlag;


enum EBPackageScriptType {
    kPackagePreinstallScript = 0x1,
    kPackagePostinstallScript = 0x2,
    kPackageWirelessPreinstall = 0x3, // Its for a future kext-support plug-in.
    kPackageEthernetPreinstall = 0x4  // ^^
}EBPackageScriptType;
#endif
