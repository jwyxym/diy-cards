--姦淫的使徒
local s,id,o=GetID()
function s.initial_effect(c)
	--卡组检索
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--抽卡    
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES_SELF+CATEGORY_HANDES_OPPO)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o*10000)
	e3:SetCondition(s.drcon)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
    local e4=e3:Clone()
	e4:SetCode(EVENT_BE_MATERIAL)
    e4:SetCondition(s.tdrcon)
    e4:SetOperation(s.tdrop)
	c:RegisterEffect(e4)
end
function s.thfilter(c)
	return c:IsSetCard(0x5ca1) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_FUSION)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsPlayerCanDraw(tp,1) and Duel.GetLP(tp)>=400 
    local b2=Duel.IsPlayerCanDraw(1-tp,1) and Duel.GetLP(1-tp)>=400 
	if chk==0 then return (b1 and b2) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLP(tp)<400 or Duel.GetLP(1-tp)<400 then return end
    local lp1=400
    local lp2=400
    local dr=0
    local dr=0
    local ct1=0
    local ct2=0
    if Duel.PayLPCost(tp,lp1)~=0 then dr1=math.floor(lp1/400) end
	if Duel.PayLPCost(1-tp,lp2)~=0 then dr2=math.floor(lp2/400) end
    if dr1~=0 then ct1=Duel.Draw(tp,dr1,REASON_EFFECT) end
    if dr2~=0 then ct2=Duel.Draw(1-tp,dr2,REASON_EFFECT) end
    if ct1~=0 or ct2~=0 then
    	Duel.BreakEffect()
        local tt1=ct1-1
        local tt2=ct2-1
        if tt1>0 then Duel.DiscardHand(tp,nil,tt1,tt1,REASON_EFFECT+REASON_DISCARD,nil) end    
        if tt2>0 then Duel.DiscardHand(1-tp,nil,tt2,tt2,REASON_EFFECT+REASON_DISCARD,nil) end    
    end
end
function s.tdrcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_FUSION and c:IsReason(REASON_EFFECT)
end
function s.tdrop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLP(tp)<400 or Duel.GetLP(1-tp)<400 then return end
    local lp1=400
    local lp2=400
    if Duel.GetLP(tp)>=800 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
    	lp1=800
    end
    local dr=0
    local dr=0
    local ct1=0
    local ct2=0
    if Duel.PayLPCost(tp,lp1)~=0 then dr1=math.floor(lp1/400) end
	if Duel.PayLPCost(1-tp,lp2)~=0 then dr2=math.floor(lp2/400) end
    if dr1~=0 then ct1=Duel.Draw(tp,dr1,REASON_EFFECT) end
    if dr2~=0 then ct2=Duel.Draw(1-tp,dr2,REASON_EFFECT) end
    if ct1>=2 or ct2>=2 then
    	Duel.BreakEffect()
        local tt1=ct1-1
        local tt2=ct2-1
        if tt1>0 then Duel.DiscardHand(tp,nil,tt1,tt1,REASON_EFFECT+REASON_DISCARD,nil) end    
        if tt2>0 then Duel.DiscardHand(1-tp,nil,tt2,tt2,REASON_EFFECT+REASON_DISCARD,nil) end
    end
end