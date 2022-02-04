#include "pch.h"
#include "scriptmainmenupromos.h"
#include "squirrel.h"
#include "masterserver.h"
#include "dedicated.h"

// mirror this in script
enum eMainMenuPromoDataProperty
{
	newInfoTitle1,
	newInfoTitle2,
	newInfoTitle3,

	largeButtonTitle,
	largeButtonText,
	largeButtonUrl,
	largeButtonImageIndex,

	smallButton1Title,
	smallButton1Url,
	smallButton1ImageIndex,

	smallButton2Title,
	smallButton2Url,
	smallButton2ImageIndex
};

// void function NSRequestCustomMainMenuPromos()
SQRESULT SQ_RequestCustomMainMenuPromos(void* sqvm)
{
	g_MasterServerManager->RequestMainMenuPromos();
	return SQRESULT_NULL;
}

// bool function NSHasCustomMainMenuPromoData()
SQRESULT SQ_HasCustomMainMenuPromoData(void* sqvm)
{
	ClientSq_pushbool(sqvm, g_MasterServerManager->m_bHasMainMenuPromoData);
	return SQRESULT_NOTNULL;
}

// var function NSGetCustomMainMenuPromoData( int promoDataKey )
SQRESULT SQ_GetCustomMainMenuPromoData(void* sqvm)
{
	if (!g_MasterServerManager->m_bHasMainMenuPromoData)
		return SQRESULT_NULL;

	switch (ClientSq_getinteger(sqvm, 1))
	{
	case eMainMenuPromoDataProperty::newInfoTitle1:
	{
		ClientSq_pushstring(sqvm, g_MasterServerManager->m_MainMenuPromoData.newInfoTitle1.c_str(), -1);
		break;
	}

	case eMainMenuPromoDataProperty::newInfoTitle2:
	{
		ClientSq_pushstring(sqvm, g_MasterServerManager->m_MainMenuPromoData.newInfoTitle2.c_str(), -1);
		break;
	}

	case eMainMenuPromoDataProperty::newInfoTitle3:
	{
		ClientSq_pushstring(sqvm, g_MasterServerManager->m_MainMenuPromoData.newInfoTitle3.c_str(), -1);
		break;
	}

	case eMainMenuPromoDataProperty::largeButtonTitle:
	{
		ClientSq_pushstring(sqvm, g_MasterServerManager->m_MainMenuPromoData.largeButtonTitle.c_str(), -1);
		break;
	}

	case eMainMenuPromoDataProperty::largeButtonText:
	{
		ClientSq_pushstring(sqvm, g_MasterServerManager->m_MainMenuPromoData.largeButtonText.c_str(), -1);
		break;
	}

	case eMainMenuPromoDataProperty::largeButtonUrl:
	{
		ClientSq_pushstring(sqvm, g_MasterServerManager->m_MainMenuPromoData.largeButtonUrl.c_str(), -1);
		break;
	}

	case eMainMenuPromoDataProperty::largeButtonImageIndex:
	{
		ClientSq_pushinteger(sqvm, g_MasterServerManager->m_MainMenuPromoData.largeButtonImageIndex);
		break;
	}

	case eMainMenuPromoDataProperty::smallButton1Title:
	{
		ClientSq_pushstring(sqvm, g_MasterServerManager->m_MainMenuPromoData.smallButton1Title.c_str(), -1);
		break;
	}

	case eMainMenuPromoDataProperty::smallButton1Url:
	{
		ClientSq_pushstring(sqvm, g_MasterServerManager->m_MainMenuPromoData.smallButton1Url.c_str(), -1);
		break;
	}

	case eMainMenuPromoDataProperty::smallButton1ImageIndex:
	{
		ClientSq_pushinteger(sqvm, g_MasterServerManager->m_MainMenuPromoData.smallButton1ImageIndex);
		break;
	}

	case eMainMenuPromoDataProperty::smallButton2Title:
	{
		ClientSq_pushstring(sqvm, g_MasterServerManager->m_MainMenuPromoData.smallButton2Title.c_str(), -1);
		break;
	}

	case eMainMenuPromoDataProperty::smallButton2Url:
	{
		ClientSq_pushstring(sqvm, g_MasterServerManager->m_MainMenuPromoData.smallButton2Url.c_str(), -1);
		break;
	}

	case eMainMenuPromoDataProperty::smallButton2ImageIndex:
	{
		ClientSq_pushinteger(sqvm, g_MasterServerManager->m_MainMenuPromoData.smallButton2ImageIndex);
		break;
	}
	}

	return SQRESULT_NOTNULL;
}

void InitialiseScriptMainMenuPromos(HMODULE baseAddress)
{
	if (IsDedicated())
		return;

	g_UISquirrelManager->AddFuncRegistration("void", "NSRequestCustomMainMenuPromos", "", "", SQ_RequestCustomMainMenuPromos);
	g_UISquirrelManager->AddFuncRegistration("bool", "NSHasCustomMainMenuPromoData", "", "", SQ_HasCustomMainMenuPromoData);
	g_UISquirrelManager->AddFuncRegistration("var", "NSGetCustomMainMenuPromoData", "int promoDataKey", "", SQ_GetCustomMainMenuPromoData);
}