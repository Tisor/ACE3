class CfgWeapons {
    class ACE_ItemCore;
    class InventoryItem_Base_F;

    class ACE_EarPlugs: ACE_ItemCore {
        displayName = "$STR_ACE_Hearing_EarPlugs_Name";
        descriptionShort = "$STR_ACE_Hearing_EarPlugs_Description";
        model = PATHTOF(ACE_earplugs.p3d);
        picture = PATHTOF(UI\ACE_earplugs_x_ca.paa);
        scope = 2;
        class ItemInfo: InventoryItem_Base_F {
            mass = 1;
        };
    };
};
