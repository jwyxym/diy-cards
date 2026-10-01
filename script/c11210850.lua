--引路人 罗塔
local s,id,o=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	aux.AddXyzProcedureLevelFree(c,s.mfilter,nil,2,2)
    --im
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
    --des
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCondition(s.stcon)
    e3:SetCost(s.stcost)
	e3:SetTarget(s.sttg)
	e3:SetOperation(s.stop)
	c:RegisterEffect(e3)
    --atkup
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetCondition(s.adcon)
	e4:SetValue(800)
	c:RegisterEffect(e4)
end
function s.mfilter(c,xyzc)
	return c:IsXyzLevel(xyzc,8) or c:IsAttackAbove(2800)
end
function s.efilter(e,te)
    local c=e:GetHandler()
     local tp = e:GetHandlerPlayer()
    local tc = te:GetHandler()
     if tc:GetControler() ~= tp and tc:IsOnField() then
        return not c:GetColumnGroup():IsContains(tc)
    end
end

function s.stcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
function s.stcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetOverlayCount()>0 end
	local ct=c:GetOverlayCount()
	c:RemoveOverlayCard(tp,ct,ct,REASON_COST)
	e:SetLabel(ct)
end
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local ct=e:GetLabel()
    if chkc then return chkc:IsOnField() end
	if chk==0 then return   Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function s.stop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

function s.adcon(e)
	return e:GetHandler():GetOverlayCount()==0
end