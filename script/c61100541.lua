--山樱「霜月」
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcCode3(c,61100533,61100536,61100537,false,false)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0a:SetRange(LOCATION_MZONE)
	e0a:SetCondition(s.descon)
	e0a:SetOperation(s.vop)
	c:RegisterEffect(e0a)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.con)
	e2:SetTarget(s.copytg)
	e2:SetOperation(s.copyop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOEXTRA+CATEGORY_DESTROY+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+10000)
	e3:SetCondition(s.tdcon)
	e3:SetCost(s.tdcost)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
	s.shanyings_effect=e1
	s.shanyingd_effect=e3
	
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(id+20000)==0 or c:GetFlagEffect(id+10000)>0
end
function s.efffilter1(c,e,tp,eg,ep,ev,re,r,rp)
	if not (c:IsSetCard(0x57b) and c:IsType(TYPE_FUSION) and not c:IsCode(id)) then return false end
	local te=c.shanyings_effect
	if not te then return false end
	local tg=te:GetTarget()
	return not tg or tg(e,tp,eg,ep,ev,re,r,rp,0,nil,c)
end
function s.efffilter2(c,e,tp,eg,ep,ev,re,r,rp)
	if not (c:IsSetCard(0x57b) and c:IsType(TYPE_FUSION) and not c:IsCode(id)) then return false end
	local te=c.shanyingd_effect
	if not te then return false end
	local tg=te:GetTarget()
	return not tg or tg(e,tp,eg,ep,ev,re,r,rp,0,nil,c)
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.IsExistingMatchingCard(s.efffilter1,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp,eg,ep,ev,re,r,rp)
	local b2=Duel.IsExistingMatchingCard(s.efffilter2,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp,eg,ep,ev,re,r,rp)
	if chk==0 then
		return b1 or b2 end
		local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(id,5)},{b2,aux.Stringid(id,6)})
		if op==1 then
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.efffilter1,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	local tc=g:GetFirst()
	local te=tc.shanyings_effect
	if tc and tc:IsLocation(LOCATION_GRAVE) then
		Duel.HintSelection(g)
	elseif tc and tc:IsLocation(LOCATION_EXTRA) then
		Duel.ConfirmCards(1-tp,tc)
	end
	e:SetProperty(te:GetProperty())
	Duel.ClearTargetCard()
	e:SetLabelObject(te)
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	Duel.ClearOperationInfo(0)
		elseif op==2 then
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.efffilter2,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	local tc=g:GetFirst()
	local te=tc.shanyingd_effect
	if tc and tc:IsLocation(LOCATION_GRAVE) then
		Duel.HintSelection(g)
	elseif tc and tc:IsLocation(LOCATION_EXTRA) then
		Duel.ConfirmCards(1-tp,tc)
	end
	e:SetProperty(te:GetProperty())
	Duel.ClearTargetCard()
	e:SetLabelObject(te)
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	Duel.ClearOperationInfo(0)
	end
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
function s.filter15(c)
	return c:IsType(TYPE_FUSION)
end

function s.vop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetMaterial():FilterCount(s.filter15,nil)
	if ct>1 then
	c:RegisterFlagEffect(id+10000,RESET_EVENT+RESETS_STANDARD,0,1)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	end 
end
function s.fusmatchk(c)
	if not c:IsSummonType(SUMMON_TYPE_FUSION) then return false end
	local mat=c:GetMaterial()
	return #mat>=2 and mat:IsExists(Card.IsType,2,nil,TYPE_MONSTER)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g1=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_SZONE,nil)
	local g2=nil
	if s.fusmatchk(e:GetHandler()) then
		g2=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	end
	local c=e:GetHandler()
	c:RegisterFlagEffect(id+20000,RESET_EVENT+RESETS_STANDARD,0,1)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g1,#g1,0,0)
	if g2 then
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g2,#g2,0,0)
	end
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_SZONE,nil)
	for tc in aux.Next(g1) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	if s.fusmatchk(c) then
		local g2=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
		for tc in aux.Next(g2) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and c:IsLocation(LOCATION_GRAVE)
end

function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	Duel.PayLPCost(tp,800)
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,nil) and e:GetHandler():IsAbleToDeck() end
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then 
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,nil)
	if #g==0 then return end
	local cnt=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	local drawnum=math.floor(cnt/8)
	if drawnum>0 then
		Duel.Draw(tp,drawnum,REASON_EFFECT)
		end
	end
end