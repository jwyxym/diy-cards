--梭巡游侠 等价
function c16820080.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c,false)
	c:EnableReviveLimit()
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	--special summon rule
	local e01=Effect.CreateEffect(c)
	e01:SetType(EFFECT_TYPE_FIELD)
	e01:SetCode(EFFECT_SPSUMMON_PROC)
	e01:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e01:SetRange(LOCATION_EXTRA)
	e01:SetCondition(c16820080.sprcon)
	e01:SetTarget(c16820080.sprtg)
	e01:SetOperation(c16820080.sprop)
	c:RegisterEffect(e01)
	--splimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetTargetRange(1,0)
	e1:SetCondition(c16820080.splimcon)
	e1:SetTarget(c16820080.splimit1)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,16820080)
	e2:SetCondition(c16820080.con)
	e2:SetCost(c16820080.cost)
	e2:SetTarget(c16820080.tg)
	e2:SetOperation(c16820080.op)
	c:RegisterEffect(e2)
	local e22=e2:Clone()
	e22:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e22)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,16820080+1)
	e3:SetCost(c16820080.spcost)
	e3:SetTarget(c16820080.sptg)
	e3:SetOperation(c16820080.spop)
	c:RegisterEffect(e3)
	--change level
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CHANGE_LEVEL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetValue(1)
	e4:SetTarget(c16820080.lvtg)
	c:RegisterEffect(e4)
	--pendulum
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_LEAVE_GRAVE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,16820080+2)
	e5:SetTarget(c16820080.pentg)
	e5:SetOperation(c16820080.penop)
	c:RegisterEffect(e5)
	c16820080.discard_effect=e3
	Duel.AddCustomActivityCounter(16820080,ACTIVITY_SPSUMMON,c16820080.counterfilter)
end
function c16820080.counterfilter(c)
	return c:IsLevel(1) or c:IsRank(1) or c:IsLink(1)
end
function c16820080.lvtg(e,c)
	return c:IsLevelAbove(1) and c:IsSummonLocation(0x1)
end
function c16820080.splimcon(e)
	return not e:GetHandler():IsForbidden()
end
function c16820080.splimit1(e,c,tp,sumtp,sumpos)
	return not c:IsLevel(1) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function c16820080.cfilter(c,sp)
	return c:IsSummonPlayer(sp)
end
function c16820080.con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c16820080.cfilter,1,nil,1-tp)
end
function c16820080.costfilter(c)
	local te=c.discard_effect
	if not te then return false end
	local tg=te:GetTarget()
	return c:IsFaceupEx() and c:IsAbleToDeckOrExtraAsCost()
		and not tg or tg and tg(e,tp,eg,ep,ev,re,r,rp,0,nil,c)
end
function c16820080.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c16820080.costfilter,tp,0x30,0,1,nil)
		and c:IsAbleToDeckOrExtraAsCost() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,c16820080.costfilter,tp,0x30,0,1,1,nil)
	e:SetLabelObject(g:GetFirst())
	g:AddCard(c)
	Duel.HintSelection(g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function c16820080.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetLabelObject()
	Duel.ClearTargetCard()
	local te=tc.discard_effect
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
end
function c16820080.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local te=tc.discard_effect
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
function c16820080.sprfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
end
function c16820080.fselect(g,tp,sc)
	if Duel.GetLocationCountFromEx(tp,tp,g,sc)<=0 then return false end
	return aux.gffcheck(g,Card.IsLevel,1,aux.NOT(Card.IsLevelAbove),1)
end
function c16820080.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(c16820080.sprfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c16820080.fselect,2,2,tp,c)
end
function c16820080.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(c16820080.sprfilter,tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:SelectSubGroup(tp,c16820080.fselect,true,2,2,tp,c)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function c16820080.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
function c16820080.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(16820080,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(c16820080.splimit)
	Duel.RegisterEffect(e1,tp)
end
function c16820080.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsLevel(1) and not c:IsRank(1) and not c:IsLink(1)
end
function c16820080.spfilter(c,e,tp)
	return c:IsSetCard(0xdf28) and c:IsFaceupEx() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c16820080.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c16820080.spfilter,tp,0x21,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x21)
end
function c16820080.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c16820080.spfilter,tp,0x21,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c16820080.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function c16820080.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end