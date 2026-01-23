--命运的邂逅
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetValue(aux.FALSE)
	c:RegisterEffect(e0)
	--spsummon
	local e01=Effect.CreateEffect(c)
	e01:SetType(EFFECT_TYPE_FIELD)
	e01:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e01:SetCode(EFFECT_SPSUMMON_PROC)
	e01:SetRange(LOCATION_EXTRA)
	e01:SetCondition(s.hspcon)
	e01:SetTarget(s.hsptg)
	e01:SetOperation(s.hspop)
	c:RegisterEffect(e01)
	--place
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,16820570)
	e1:SetTarget(c16820570.target)
	e1:SetOperation(c16820570.operation)
	c:RegisterEffect(e1)
	--spsummon spell
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.spstg)
	e2:SetOperation(s.spsop)
	c:RegisterEffect(e2)
end
function s.sfilter(c,e,tp)
	return c:GetOriginalType()&TYPE_MONSTER>0
		and (c:GetType()&(TYPE_CONTINUOUS+TYPE_SPELL)==TYPE_CONTINUOUS+TYPE_SPELL
		or c:GetType()&(TYPE_CONTINUOUS+TYPE_TRAP)==TYPE_CONTINUOUS+TYPE_TRAP)
		and c:IsFaceup() and c:IsAbleToGrave()
end
function s.spstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.sfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.sfilter,tp,LOCATION_ONFIELD,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.spsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,0x40)>0 and tc:IsLocation(0x10) then
		if c:IsRelateToChain() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			local e1=Effect.CreateEffect(c)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			c:RegisterEffect(e1)
		end
	end
end
function c16820570.filter(c)
	return not c:IsForbidden() and c:IsCode(16820550,16820555)
end
function c16820570.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c16820570.filter,tp,0x11,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
function c16820570.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c16820570.filter),tp,0x11,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			local e1=Effect.CreateEffect(c)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			tc:RegisterEffect(e1)
		end
	end
end
function s.sprfilter(c,sc)
	return c:GetOriginalType()&TYPE_MONSTER~=0 and c:IsFaceup()
		and c:IsAbleToGraveAsCost() and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
function s.sgchk(g,tp,sc)
	return Duel.GetLocationCountFromEx(tp,tp,g,sc)>0
		and g:GetClassCount(Card.GetOriginalAttribute)==1
		and g:GetClassCount(Card.GetOriginalRace)==2
end
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_SZONE,0,c,c)
	return g:CheckSubGroup(s.sgchk,2,2,tp,c)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local cp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.sprfilter,cp,LOCATION_SZONE,0,c,c)
	Duel.Hint(HINT_SELECTMSG,cp,HINTMSG_TOGRAVE)
	local sg=g:SelectSubGroup(cp,s.sgchk,true,2,2,cp,c)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	c:SetMaterial(sg)
	Duel.SendtoGrave(sg,REASON_SPSUMMON)
end