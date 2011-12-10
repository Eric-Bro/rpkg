//
//  EBPackageTemplates_defines.h
//  

#ifndef EBPackageTemplates_defines_h
	#define EBPackageTemplates_defines_h

#define cstring(x) [(x) cStringUsingEncoding: NSUTF8StringEncoding]
#define flag(x,y) ((y) & (x)) == (x)

/*!
 * index.xml
 */
#define packme_index_templates_body \
@"<pkmkdoc spec=\"1.12\"><properties><title>[_btitle_]</title><organization>[_borganizationID_]</organization>[_buiModeType_]<min-target os=\"[_bminimumTargetOS_]\"/>[_idomains_]</properties><distribution><versions min-spec=\"1.000000\"/><scripts></scripts></distribution><contents>[_bchoisesection_]</contents>[_bresourcessection_]<flags/>[_bfilesssection_][_bmods_]</pkmkdoc>"

#define packme_index_templates_choise_section \
@"<choice title=\"[_citemTitle_]\" id=\"[_citemID_]\" description=\"[_citemdescription_]\" starts_selected=\"[_citemSelectedAtStart_]\" starts_enabled=\"[_citemEnabledAtStart]\" starts_hidden=\"[_citemHiddenAtStart_]\">[_crefssection_]"
#define packme_index_templates_choise_section_close_tag @"</choice>"
#define packme_index_templates_refs  @"<pkgref id=\"[_rpkgID_]\"/>"
#define packme_index_templates_items @"<item type=\"file\">[_ipkgXMLFile_]</item>"

/* @New templates */
/* NOTE: rtf text must be written using CDATA */
#define packme_index_templates_resources_section @"<resources bg-scale=\"[_rbgscale_]\" bg-align=\"[_rbgalign_]\">[_rsectioncontent_]</resources>" 
#define packme_index_templates_resources_locale_section  @"<locale lang=\"[_rlocalelanguage_]\">[_rlocalecontent_]</locale>"
#define packme_index_templates_resources_locale_no_files @"<locale lang=\"[_rlocalelanguage_]\"/>"
#define packme_index_templates_resources_background @"<resource mod=\"true\" type=\"background\">[_rbackgroundpath_]</resource>"
#define packme_index_templates_resources_file_embedded @"<resource mime-type=\"[_rfilemimetype_]\" kind=\"embedded\" type=\"[_rfiletype_]\">[_rfilecontent_]</resource>"
#define packme_index_templates_resources_file_external @"<resource mod=\"true\" type=\"[_rfiletype_]\">[_rfilecontent_]</resource>"
/* @end */

#define packme_index_templates_ui_mode_easy   @"<userSees ui=\"easy\"/>"
#define packme_index_templates_ui_mode_custom @"<userSees ui=\"custom\"/>"
#define packme_index_templates_ui_mode_both   @"<userSees ui=\"both\"/>"

#define packme_index_templates_domain          @"<domain*/>" 
#define packme_index_templates_domain_anywhere @" anywhere=\"true\""
#define packme_index_templates_domain_system   @" system=\"true\""
#define packme_index_templates_domain_user     @" user=\"true\""

#define packme_index_templates_mod_domain_anywhere @"<mod>properties.anywhereDomain</mod>"
#define packme_index_templates_mod_domain_system   @"<mod>properties.userDomain</mod>"
#define packme_index_templates_mod_domain_user     @"<mod>properties.systemDomain</mod>"

/* Keys : */
#define packme_index_keys_title            @"[_btitle_]"
#define packme_index_keys_target           @"[_boutputFileName_]"
#define packme_index_keys_organization     @"[_borganizationID_]"
#define packme_index_keys_ui_mode          @"[_buiModeType_]"
#define packme_index_keys_min_target_os    @"[_bminimumTargetOS_]"
#define packme_index_keys_domain_flags     @"[_idomains_]"
#define packme_index_keys_choise_section   @"[_bchoisesection_]"
#define packme_index_keys_files_section    @"[_bfilesssection_]"
#define packme_index_keys_refs_section     @"[_crefssection_]"
#define packme_index_keys_mods             @"[_bmods_]"
#define packme_index_keys_item_title       @"[_citemTitle_]"
#define packme_index_keys_item_id          @"[_citemID_]"
#define packme_index_keys_item_description @"[_citemdescription_]"
#define packme_index_keys_item_selected    @"[_citemSelectedAtStart_]"
#define packme_index_keys_item_enabled     @"[_citemEnabledAtStart]"
#define packme_index_keys_item_hidden      @"[_citemHiddenAtStart_]"
#define packme_index_keys_refs_id          @"[_rpkgID_]"
#define packme_index_keys_xml_filename     @"[_ipkgXMLFile_]"
#define packme_index_keys_resources_section  @"[_bresourcessection_]"
#define packme_index_keys_resources_bg_scale @"[_rbgscale_]"
#define packme_index_keys_resources_bg_align @"[_rbgalign_]"
#define packme_index_keys_resources_section_content @"[_rsectioncontent_]"
#define packme_index_keys_resources_locale_language @"[_rlocalelanguage_]"
#define packme_index_keys_resources_locale_section_content @"[_rlocalecontent_]"
#define packme_index_keys_resources_background_filepath    @"[_rbackgroundpath_]"

#define packme_index_keys_resources_file_general_type      @"[_rfiletype_]"
#define packme_index_keys_resources_file_general_content   @"[_rfilecontent_]"
#define packme_index_keys_resources_file_embedded_mimetype @"[_rfilemimetype_]"


/*!
 * {item_name}.xml
 */
#define packme_info_templates_body \
@"<pkgref spec='1.12' uuid='[_fuuid_]'><config><identifier>[_fpkgid_]</identifier><version>1.0</version><post-install type='none'/><installFrom[_fincrootattribute_]>[_fsourcePath_]</installFrom><installTo mod='true'>[_fdestinationPath_]</installTo><flags><followSymbolicLinks/></flags><packageStore type=\"internal\"/><mod>installTo.path</mod><mod>identifier</mod>[_fincludecfolder_]<mod>parent</mod><mod>installTo</mod></config><scripts>[_fscriptssection_]</scripts><contents><file-list>[_fsecondFilename_]</file-list>[_fcomponentsection_]<filter>/CVS$</filter><filter>/\\.svn$</filter><filter>/\\.cvsignore$</filter><filter>/\\.cvspass$</filter><filter>/\\.DS_Store$</filter></contents></pkgref>"

#define packme_info_templates_preinstall_script  @"<preinstall mod=\"true\">*</preinstall>"
#define packme_info_templates_postinstall_script @"<postinstall mod=\"true\">*</postinstall>"

#define packme_info_templates_require_authorization     @"<requireAuthorization/>"
#define packme_info_templates_include_containing_folder @"<mod>includeRoot</mod>"

#define packme_info_templates_component @"<component id=\"[_fcomponentid_]\" path=\"[_fcomponentpath_]\" version=\"[_fcomponentversion_]\"><version-plist>[_fcomponentverplistpath_]</version-plist></component>"
#define packme_info_templates_include_root_attribute @" includeRoot=\"true\""

/* Keys: */
#define packme_info_keys_uuid         @"[_fuuid_]"
#define packme_info_keys_id           @"[_fpkgid_]"
#define packme_info_keys_version      @"[_fversion_]"
#define packme_info_keys_require_auth @"[_frequireAuthorization_]"
#define packme_info_keys_source_path  @"[_fsourcePath_]"
#define packme_info_keys_destination  @"[_fdestinationPath_]"
#define packme_info_keys_mods         @"[_fmods_]"
#define packme_info_keys_include_containing_folder @"[_fincludecfolder_]"
#define packme_info_keys_include_root_attribute @"[_fincrootattribute_]"
#define packme_info_keys_scripts_section   @"[_fscriptssection_]"
#define packme_info_keys_contents_filename @"[_fsecondFilename_]"
#define packme_info_keys_component_section @"[_fcomponentsection_]"
#define packme_info_keys_component_id @"[_fcomponentid_]"
#define packme_info_keys_component_path @"[_fcomponentpath_]"
#define packme_info_keys_component_version @"[_fcomponentversion_]"
#define packme_info_keys_component_version_plist @"[_fcomponentverplistpath_]"

/*!
 * {item_name}+contents.xml
 */
#define packme_contents_templates_root_folder @"<f n='[_cfilename_]' o='[_cowner_]' g='[_cgroup_]' p='16877' pt='[_cpath_]' m='true' t='file'>"
#define packme_contents_templates_root_file   @"<f n='[_cfilename_]' o='[_cowner_]' g='[_cgroup_]' p='33188' pt='[_cpath_]' m='true' t='file'/>"
#define packme_contents_templates_folder      @"<f n='[_cfilename_]' o='[_cowner_]' g='[_cgroup_]' p='33188'/>"
#define packme_contents_templates_file        @"<f n='[_cfilename_]' o='[_cowner_]' g='[_cgroup_]' p='16877'>"
#define packme_contents_templates_open_tag    @"<pkg-contents spec='1.12'>"
#define packme_contents_templates_close_tag   @"</pkg-contents>"

/* Keys: */
#define packme_contents_keys_filename    @"[_cfilename_]"
#define packme_contents_keys_owner       @"[_cowner_]"
#define packme_contents_keys_owner_group @"[_cgroup_]"
#define packme_contents_keys_path        @"[_cpath_]"

#endif
