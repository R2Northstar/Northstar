#include "pch.h"
#include "squirrel/squirrel.h"
#include "masterserver/masterserver.h"

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
ADD_SQFUNC("void", NSRequestCustomMainMenuPromos, "", "", ScriptContext::UI)
{
	g_pMasterServerManager->RequestMainMenuPromos();
	return SQRESULT_NULL;
}

ADD_SQFUNC("bool", NSHasCustomMainMenuPromoData, "", "", ScriptContext::UI)
{
	g_pSquirrel<ScriptContext::UI>->pushbool(sqvm, g_pMasterServerManager->m_bHasMainMenuPromoData);
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("var", NSGetCustomMainMenuPromoData, "int promoDataKey", "", ScriptContext::UI)
{
	if (!g_pMasterServerManager->m_bHasMainMenuPromoData)
		return SQRESULT_NULL;

	switch (g_pSquirrel<ScriptContext::UI>->getinteger(sqvm, 1))
	{
	case eMainMenuPromoDataProperty::newInfoTitle1:
	{
		g_pSquirrel<ScriptContext::UI>->pushstring(sqvm, g_pMasterServerManager->m_sMainMenuPromoData.newInfoTitle1.c_str());
		break;
	}

	case eMainMenuPromoDataProperty::newInfoTitle2:
	{
		g_pSquirrel<ScriptContext::UI>->pushstring(sqvm, g_pMasterServerManager->m_sMainMenuPromoData.newInfoTitle2.c_str());
		break;
	}

	case eMainMenuPromoDataProperty::newInfoTitle3:
	{
		g_pSquirrel<ScriptContext::UI>->pushstring(sqvm, g_pMasterServerManager->m_sMainMenuPromoData.newInfoTitle3.c_str());
		break;
	}

	case eMainMenuPromoDataProperty::largeButtonTitle:
	{
		g_pSquirrel<ScriptContext::UI>->pushstring(sqvm, g_pMasterServerManager->m_sMainMenuPromoData.largeButtonTitle.c_str());
		break;
	}

	case eMainMenuPromoDataProperty::largeButtonText:
	{
		g_pSquirrel<ScriptContext::UI>->pushstring(sqvm, g_pMasterServerManager->m_sMainMenuPromoData.largeButtonText.c_str());
		break;
	}

	case eMainMenuPromoDataProperty::largeButtonUrl:
	{
		g_pSquirrel<ScriptContext::UI>->pushstring(sqvm, g_pMasterServerManager->m_sMainMenuPromoData.largeButtonUrl.c_str());
		break;
	}

	case eMainMenuPromoDataProperty::largeButtonImageIndex:
	{
		g_pSquirrel<ScriptContext::UI>->pushinteger(sqvm, g_pMasterServerManager->m_sMainMenuPromoData.largeButtonImageIndex);
		break;
	}

	case eMainMenuPromoDataProperty::smallButton1Title:
	{
		g_pSquirrel<ScriptContext::UI>->pushstring(sqvm, g_pMasterServerManager->m_sMainMenuPromoData.smallButton1Title.c_str());
		break;
	}

	case eMainMenuPromoDataProperty::smallButton1Url:
	{
		g_pSquirrel<ScriptContext::UI>->pushstring(sqvm, g_pMasterServerManager->m_sMainMenuPromoData.smallButton1Url.c_str());
		break;
	}

	case eMainMenuPromoDataProperty::smallButton1ImageIndex:
	{
		g_pSquirrel<ScriptContext::UI>->pushinteger(sqvm, g_pMasterServerManager->m_sMainMenuPromoData.smallButton1ImageIndex);
		break;
	}

	case eMainMenuPromoDataProperty::smallButton2Title:
	{
		g_pSquirrel<ScriptContext::UI>->pushstring(sqvm, g_pMasterServerManager->m_sMainMenuPromoData.smallButton2Title.c_str());
		break;
	}

	case eMainMenuPromoDataProperty::smallButton2Url:
	{
		g_pSquirrel<ScriptContext::UI>->pushstring(sqvm, g_pMasterServerManager->m_sMainMenuPromoData.smallButton2Url.c_str());
		break;
	}

	case eMainMenuPromoDataProperty::smallButton2ImageIndex:
	{
		g_pSquirrel<ScriptContext::UI>->pushinteger(sqvm, g_pMasterServerManager->m_sMainMenuPromoData.smallButton2ImageIndex);
		break;
	}
	}

	return SQRESULT_NOTNULL;
}
