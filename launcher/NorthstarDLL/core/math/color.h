#pragma once

struct color24
{
	uint8_t r, g, b;
};

typedef struct color32_s
{
	bool operator!=(const struct color32_s& other) const
	{
		return r != other.r || g != other.g || b != other.b || a != other.a;
	}
	inline unsigned* asInt(void)
	{
		return reinterpret_cast<unsigned*>(this);
	}
	inline const unsigned* asInt(void) const
	{
		return reinterpret_cast<const unsigned*>(this);
	}
	inline void Copy(const color32_s& rhs)
	{
		*asInt() = *rhs.asInt();
	}

	uint8_t r, g, b, a;
} color32;

struct SourceColor
{
	unsigned char R;
	unsigned char G;
	unsigned char B;
	unsigned char A;

	SourceColor(unsigned char r, unsigned char g, unsigned char b, unsigned char a)
	{
		R = r;
		G = g;
		B = b;
		A = a;
	}

	SourceColor()
	{
		R = 0;
		G = 0;
		B = 0;
		A = 0;
	}
};

//-----------------------------------------------------------------------------
// Purpose: Basic handler for an rgb set of colors
//			This class is fully inline
//-----------------------------------------------------------------------------
class Color
{
  public:
	Color(int r, int g, int b, int a = 255)
	{
		_color[0] = (unsigned char)r;
		_color[1] = (unsigned char)g;
		_color[2] = (unsigned char)b;
		_color[3] = (unsigned char)a;
	}
	void SetColor(int _r, int _g, int _b, int _a = 0)
	{
		_color[0] = (unsigned char)_r;
		_color[1] = (unsigned char)_g;
		_color[2] = (unsigned char)_b;
		_color[3] = (unsigned char)_a;
	}
	void GetColor(int& _r, int& _g, int& _b, int& _a) const
	{
		_r = _color[0];
		_g = _color[1];
		_b = _color[2];
		_a = _color[3];
	}
	int GetValue(int index) const
	{
		return _color[index];
	}
	void SetRawColor(int color32)
	{
		*((int*)this) = color32;
	}
	int GetRawColor(void) const
	{
		return *((int*)this);
	}

	inline int r() const
	{
		return _color[0];
	}
	inline int g() const
	{
		return _color[1];
	}
	inline int b() const
	{
		return _color[2];
	}
	inline int a() const
	{
		return _color[3];
	}

	unsigned char& operator[](int index)
	{
		return _color[index];
	}

	const unsigned char& operator[](int index) const
	{
		return _color[index];
	}

	bool operator==(const Color& rhs) const
	{
		return (*((int*)this) == *((int*)&rhs));
	}

	bool operator!=(const Color& rhs) const
	{
		return !(operator==(rhs));
	}

	Color& operator=(const Color& rhs)
	{
		SetRawColor(rhs.GetRawColor());
		return *this;
	}

	Color& operator=(const color32& rhs)
	{
		_color[0] = rhs.r;
		_color[1] = rhs.g;
		_color[2] = rhs.b;
		_color[3] = rhs.a;
		return *this;
	}

	color32 ToColor32(void) const
	{
		color32 newColor {};
		newColor.r = _color[0];
		newColor.g = _color[1];
		newColor.b = _color[2];
		newColor.a = _color[3];
		return newColor;
	}

	std::string ToANSIColor()
	{
		std::string out = "\033[38;2;";
		out += std::to_string(_color[0]) + ";";
		out += std::to_string(_color[1]) + ";";
		out += std::to_string(_color[2]) + ";";
		out += "49m";
		return out;
	}

	SourceColor ToSourceColor()
	{
		return SourceColor(_color[0], _color[1], _color[2], _color[3]);
	}

  private:
	unsigned char _color[4];
};

namespace NS::Colors
{
	extern Color SCRIPT_UI;
	extern Color SCRIPT_CL;
	extern Color SCRIPT_SV;
	extern Color NATIVE_UI;
	extern Color NATIVE_CL;
	extern Color NATIVE_SV;
	extern Color NATIVE_ENGINE;
	extern Color FILESYSTEM;
	extern Color RPAK;
	extern Color NORTHSTAR;
	extern Color ECHO;

	extern Color TRACE;
	extern Color DEBUG;
	extern Color INFO;
	extern Color WARN;
	extern Color ERR;
	extern Color CRIT;
	extern Color OFF;
}; // namespace NS::Colors
