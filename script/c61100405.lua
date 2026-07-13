--均色史莱姆-灰史莱姆
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.valcon)
	c:RegisterEffect(e1)
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1a:SetValue(1)
	c:RegisterEffect(e1a)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(TIMING_MAIN_END+TIMINGS_CHECK_MONSTER)
	e3:SetCountLimit(1,id+10000)
	e3:SetCondition(s.xyzcon)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
end
function s.valcon(e,re,r,rp)
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else
		return 0
	end
end
function s.spfilter2(c,e,tp)
	return c:IsType(TYPE_MONSTER)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local b1=Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_MZONE,0,1,nil)
	local b2=Duel.IsExistingTarget(s.spfilter2,tp,0,LOCATION_MZONE,1,nil) and c:IsHasEffect(61100441) and Duel.GetFlagEffect(tp,61100441)==0
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (b1 or b2)
	end
		if b1 and not b2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_MZONE,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
		elseif b2 and not b1 then
		local g=Duel.SelectTarget(tp,s.spfilter2,tp,0,LOCATION_MZONE,1,1,nil)
		Duel.RegisterFlagEffect(tp,61100441,RESET_PHASE+PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
		elseif b1 and b2 then
		local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(61100441,0)},{b2,aux.Stringid(61100441,1)})
		if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_MZONE,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
		elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=Duel.SelectTarget(tp,s.spfilter2,tp,0,LOCATION_MZONE,1,1,nil)
		Duel.RegisterFlagEffect(tp,61100441,RESET_PHASE+PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	if not tc:IsRelateToEffect(e) then return end
	if not Duel.Equip(tp,tc,c) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	e1:SetLabelObject(c)
	tc:RegisterEffect(e1)
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function s.cfilter5(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	return ct==Duel.GetMatchingGroupCount(s.cfilter5,tp,LOCATION_MZONE,0,nil)
end

function s.exgfilter(c,mg,mc)
	return mg:CheckSubGroup(s.exgselect,1,#mg,c,mc)
end
function s.exgfilter2(c)
	return c:IsXyzType(TYPE_MONSTER)
end
function s.exgselect(g,exc,mc)
	if not g:IsContains(mc) then return false end
	if g:FilterCount(Card.IsLevel,nil,3)~=#g then return false end
	return exc:IsXyzSummonable(g)
end

function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mg=Duel.GetMatchingGroup(s.exgfilter2,tp,LOCATION_ONFIELD,0,nil)
	mg=mg:Filter(Card.IsLevel,nil,3)
	if chk==0 then return Duel.GetMatchingGroupCount(s.exgfilter,tp,LOCATION_EXTRA,0,nil,mg,c)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local mg=Duel.GetMatchingGroup(s.exgfilter2,tp,LOCATION_ONFIELD,0,nil)
	mg=mg:Filter(Card.IsLevel,nil,3)
	local exg=Duel.GetMatchingGroup(s.exgfilter,tp,LOCATION_EXTRA,0,nil,mg,c)
	if #exg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=exg:Select(tp,1,1,nil):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local msg=mg:SelectSubGroup(tp,s.exgselect,false,1,#mg,sc,c)
	if msg and #msg>0 then
		Duel.XyzSummon(tp,sc,msg)
	end
end