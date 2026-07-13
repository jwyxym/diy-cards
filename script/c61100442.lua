--本色史莱姆吞噬
local s,id,o=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.xyzcon)
	e2:SetOperation(s.xyzop)
	e2:SetValue(SUMMON_TYPE_XYZ)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_EXTRA,0)
	e3:SetCondition(s.efcon)
	e3:SetTarget(s.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(61100442)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	--c:RegisterEffect(e4)
	
end
function s.cfilter5(c)
	return c:IsFaceup() and c:IsRace(RACE_AQUA) and c:IsType(TYPE_MONSTER)
end
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	return ct==Duel.GetMatchingGroupCount(s.cfilter5,tp,LOCATION_MZONE,0,nil)
end
function s.eftg(e,c)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_XYZ) and c:IsRace(RACE_AQUA)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	return rp~=tp and re:IsActiveType(TYPE_MONSTER) and tc:IsLocation(LOCATION_MZONE+LOCATION_HAND)
end

function s.xyzfilter1(c,tc)

	return ((c:IsSetCard(0x579) and c:IsType(TYPE_XYZ) and c:IsFaceup())
	or (c:IsType(TYPE_XYZ) and c:IsFaceup() and c:GetOverlayGroup():IsExists(s.xyzfilter2,1,nil)))
	and c:GetAttack()>=tc:GetAttack() and c:IsCanBeXyzMaterial(tc)
end
function s.xyzfilter2(c)
	return c:IsSetCard(0x579) and c:IsType(TYPE_XYZ)
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=re:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter1,tp,LOCATION_MZONE,0,1,nil,tc) end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if not tc:IsRelateToEffect(re) and not (tc:IsFaceup() or tc:IsLocation(LOCATION_HAND)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local xc=Duel.SelectMatchingCard(tp,s.xyzfilter1,tp,LOCATION_MZONE,0,1,1,nil,tc):GetFirst()
	if xc then
		Duel.Overlay(xc,tc)
	end
end
function s.xyzcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,c)
end
function s.xyzfilter(c,xyzc)
	return c:IsSetCard(0x579) and c:IsType(TYPE_XYZ) and c:IsFaceup() and c:IsCanBeXyzMaterial(xyzc) --and c:IsHasEffect(61100442)
end

function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,c)
	local tc=g:GetFirst()
	if tc then
		local og=tc:GetOverlayGroup()
		if #og>0 then Duel.Overlay(c,og) end
		c:SetMaterial(g)
		Duel.Overlay(c,tc)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsRace(RACE_AQUA) and c:IsType(TYPE_XYZ))
end