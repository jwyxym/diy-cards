-- 七代码 医生兽
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_MONSTER),2,2,s.lcheck)
	c:EnableReviveLimit()
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_FIELD)
  e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
  e0:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
  e0:SetRange(LOCATION_EXTRA)
  e0:SetTargetRange(LOCATION_SZONE,0)
  e0:SetValue(s.matval)
  c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.mvtg)
	e1:SetOperation(s.mvop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.copytg)
	e2:SetOperation(s.copyop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.val)
	c:RegisterEffect(e3)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_XMATERIAL)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(1200)
	e5:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsSetCard(0xb94) end)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_ATKCHANGE)
	e6:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e6:SetCountLimit(1)
	e6:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsSetCard(0xb94) and Duel.GetTurnPlayer()==tp end)
	e6:SetTarget(s.xyztg)
	e6:SetOperation(s.xyzop)
	c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))
	e7:SetCategory(CATEGORY_ATKCHANGE)
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetRange(LOCATION_MZONE)
	e7:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e7:SetCountLimit(1)
	e7:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.GetTurnPlayer()==tp end)
	e7:SetTarget(s.xyztg)
	e7:SetOperation(s.xyzop)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e8:SetRange(LOCATION_SZONE)
	e8:SetTargetRange(LOCATION_MZONE,0)
	e8:SetTarget(s.eftg)
	e8:SetLabelObject(e7)
	c:RegisterEffect(e8)
	s.SevenCode_xyz_effect=e6
end
function s.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0xb94)
end
function s.matval(e,lc,mg,c,tp)
	if not (lc:IsSetCard(0x6c1) and e:GetHandlerPlayer()==tp) then return false,nil end
	return true,true
end
function s.mvfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0xb94) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.mvfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.mvfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	Duel.HintSelection(g)
	local tc=g:GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(s.filter,c:GetControler(),LOCATION_SZONE,0,nil)*1200
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xb94) and c:GetOriginalType()&TYPE_MONSTER~=0
end
function s.efffilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not (s.filter(c) and c:IsCanBeEffectTarget(e)) then return false end
	local te=c.SevenCode_xyz_effect
	if not te then return false end
	local tg=te:GetTarget()
	return not tg or tg(e,tp,eg,ep,ev,re,r,rp,0,nil,c)
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local mg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_SZONE,0,nil)
	if chkc then return mg:IsContains(chkc) and s.efffilter(chkc) end
	if chk==0 then
		return mg:IsExists(s.efffilter,1,nil,e,tp,eg,ep,ev,re,r,rp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=mg:FilterSelect(tp,s.efffilter,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	Duel.SetTargetCard(g)
	local tc=g:GetFirst()
	Duel.ClearTargetCard()
	e:SetLabelObject(tc)
	local te=tc.SevenCode_xyz_effect
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	Duel.ClearOperationInfo(0)
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local te=tc.SevenCode_xyz_effect
	local op=te:GetOperation()
	if tc:IsRelateToEffect(e) and op then op(e,tp,eg,ep,ev,re,r,rp) end
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)
	local sg=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	local sc=sg:GetFirst()
	if not sc then return end
	Duel.HintSelection(sg)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_TRIGGER)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	sc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(-1200)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	sc:RegisterEffect(e2)
end
function s.eftg(e,c)
	return c:IsOriginalCodeRule(11240120) or c:IsOriginalCodeRule(11240125)
end