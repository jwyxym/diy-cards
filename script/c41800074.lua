--损失回避
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--draw
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(s.drcon)
	e1:SetOperation(s.drop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(s.tdcon)
	e2:SetOperation(s.tdop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.cfilter(c,tp)
	return c:IsControler(1-tp) and not c:IsReason(REASON_DRAW) and c:IsPreviousLocation(LOCATION_DECK|LOCATION_GRAVE)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return re and ep==1-tp
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if not re:GetHandler():IsOriginalCodeRule(id) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.Draw(1-tp,1,REASON_EFFECT)
	end
	Duel.RegisterFlagEffect(1-tp,id,RESET_PHASE|PHASE_END,0,1)
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(1-tp,id)>1
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFlagEffect(1-tp,id)-1
	local hg=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	ct=math.min(ct,#hg)
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)
	local sg=hg:Select(1-tp,ct,ct,nil)
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end