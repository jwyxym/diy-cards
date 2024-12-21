--混沌之海的涟漪
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
function s.cfilter(c,tp)
	return c:IsReleasable()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(0)
	local g=Duel.GetReleaseGroup(tp,true):Filter(s.cfilter,nil,tp)
	if chk==0 then return g:GetCount()>=1 end
	local rg=g:FilterSelect(tp,s.cfilter,1,1,nil,tp)
	e:SetLabel(rg:GetFirst():GetOriginalRace())
	Duel.Release(rg,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,3,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_REMOVED)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,3,3,nil,lv)
	if g:GetCount()>0 and Duel.SendtoDeck(g,nil,2,REASON_EFFECT)~=0 and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)~=0 then
		local off=1
		local ops={}
		local opval={}
		if Duel.IsPlayerCanDraw(tp,1) then
			ops[off]=aux.Stringid(id,0)
			opval[off-1]=1
			off=off+1
		end
		if e:GetLabel()~=0
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,51900202,0,TYPES_TOKEN_MONSTER+TYPE_TUNER,2000,2000,8,e:GetLabel(),ATTRIBUTE_d) then
			ops[off]=aux.Stringid(id,1)
			opval[off-1]=2
			off=off+1
		end
		ops[off]=aux.Stringid(id,2)
		opval[off-1]=3
		off=off+1
		local op=Duel.SelectOption(tp,table.unpack(ops))
		if opval[op]==1 then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		elseif opval[op]==2 then
			Duel.BreakEffect()
			local token=Duel.CreateToken(tp,51900202)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetValue(e:GetLabel())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			token:RegisterEffect(e1)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_TUNER)
			e2:SetValue(s.tnval)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e2,true)
		Duel.SpecialSummonComplete()
		end
	end
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT,tp,true)
	end
end
function s.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler())
end