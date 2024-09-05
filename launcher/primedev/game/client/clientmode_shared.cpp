
//-----------------------------------------------------------------------------
// Some explanation might be needed for this. The crash is caused by
// us calling a pure virtual function in the constructor.
// The order goes like this:
// ctor
//   -> vftable = IPureCall::vftable
//   -> IPureCall::Ok()
//        -> IPureCall::CallMeIDareYou()
//             -> purecall_handler
//                  -> crash :(
class IPureCall
{
public:
	IPureCall() { Ok(); }

	virtual void CallMeIDareYou() = 0;

	void Ok() { CallMeIDareYou(); }
};

class CPureCall : IPureCall
{
	virtual void CallMeIDareYou() {}
};

static void (*o_pCC_crash_test_f)(const CCommand& args);
static void h_CC_crash_test_f(const CCommand& args)
{
	int crashtype = 0;
	int dummy;
	if (args.ArgC() > 1)
	{
		crashtype = atoi(args.Arg(1));
	}
	switch (crashtype)
	{
	case 0:
		dummy = *((int*)NULL);
		spdlog::info("Crashed! {}", dummy);
		break;
	case 1:
		*((int*)NULL) = 24122021;
		break;
	case 2:
		throw std::exception("Crashed!");
		break;
	case 3:
		RaiseException(7, 0, 0, NULL);
		break;
	case 4:
	{
		CPureCall PureCall;
		break;
	}
	default:
		spdlog::info("Unknown variety of crash. You have now failed to crash. I hope you're happy.");
		break;
	}
}

ON_DLL_LOAD("engine.dll", ClientModeShared, (CModule module))
{
	o_pCC_crash_test_f = module.Offset(0x15BEE0).RCast<decltype(o_pCC_crash_test_f)>();
	HookAttach(&(PVOID&)o_pCC_crash_test_f, (PVOID)h_CC_crash_test_f);
}
