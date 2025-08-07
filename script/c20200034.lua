--仙境，亦或疯狂国度
function c20200034.initial_effect(c)
	c:SetUniqueOnField(1,0,20200034)
	c:SetSPSummonOnce(20200034)
	--change code
	aux.EnableChangeCode(c,20200003,LOCATION_GRAVE+LOCATION_MZONE)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,nil,2,99,c20200034.lcheck)
	--direct attack
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e0)
	--extra material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c20200034.matval)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c20200034.atkval)
	c:RegisterEffect(e2)
	--cannot link material
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--splimit
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SPSUMMON_CONDITION)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetValue(c20200034.splimit)
	c:RegisterEffect(e4)
end
function c20200034.lfilter(c)
	return c:IsCode(20200003) and c:IsFaceup()
end
function c20200034.lcheck(g,lc,tp)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0xb31) and Duel.IsExistingMatchingCard(c20200034.lfilter,tp,LOCATION_SZONE,0,2,nil)
end
function c20200034.splimit(e,se,sp,st,pos,tp)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
		or Duel.IsExistingMatchingCard(c20200034.lfilter,sp,LOCATION_SZONE,0,2,nil)
end
function c20200034.exmatcheck(c,lc,tp)
	if not c:IsControler(1-tp) then return false end
	local le={c:IsHasEffect(EFFECT_EXTRA_LINK_MATERIAL,tp)}
	for _,te in pairs(le) do
		local f=te:GetValue()
		local related,valid=f(te,lc,nil,c,tp)
		if related and not te:GetHandler():IsCode(20200034) then return false end
	end
	return true
end
function c20200034.matval(e,lc,mg,c,tp)
	if e:GetHandler()~=lc then return false,nil end
	return true,not mg or not mg:IsExists(c20200034.exmatcheck,1,nil,lc,tp)
end
function c20200034.atkfilter(c)
	return c:IsFaceup() and c:IsCode(20200003) and c:GetSequence()~=5
end
function c20200034.atkval(e,c)
	return Duel.GetMatchingGroupCount(c20200034.atkfilter,c:GetControler(),LOCATION_SZONE,0,nil)*500
end