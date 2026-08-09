--械鳞龙魄 汞合金装甲龙
local s,id,o=GetID()
function s.initial_effect(c)
	--连接召唤
	aux.AddLinkProcedure(c,s.mfilter,2)
	c:EnableReviveLimit()
	--种族视为机械族
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_CHANGE_RACE)
	e0:SetRange(LOCATION_MZONE+LOCATION_EXTRA+LOCATION_GRAVE)
	e0:SetValue(RACE_MACHINE)
	c:RegisterEffect(e0)    
	--给与伤害    
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.damcon1)
	e1:SetOperation(s.damop1)
	c:RegisterEffect(e1)    
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.regcon)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.damcon2)
	e3:SetOperation(s.damop2)
	c:RegisterEffect(e3)
	--回到手卡        
   	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,id)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
    --提示文本 
    local e00=Effect.CreateEffect(c)
	e00:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e00:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e00:SetCode(EVENT_ADJUST)
	e00:SetRange(0xff)
	e00:SetOperation(s.adjustop)
	c:RegisterEffect(e00)
end
function s.mfilter(c)
	return c:IsLinkType(TYPE_PENDULUM) and c:GetOriginalRace()==RACE_DRAGON
end
function s.confilter(c,sp)
	return c:IsSummonPlayer(sp) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.damcon1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return false end
	local tg=g:GetMaxGroup(Card.GetAttack)
	return eg:IsExists(s.confilter,1,nil,1-tp) and not Duel.IsChainSolving() and tg:IsExists(Card.IsControler,1,nil,tp)
end
function s.damop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Damage(1-tp,400,REASON_EFFECT)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.confilter,1,nil,1-tp) and Duel.IsChainSolving()
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
function s.damcon2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return false end
	local tg=g:GetMaxGroup(Card.GetAttack)
	return e:GetHandler():GetFlagEffect(id)>0 and tg:IsExists(Card.IsControler,1,nil,tp)
end
function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetHandler():GetFlagEffect(id)
	e:GetHandler():ResetFlagEffect(id)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Damage(1-tp,ct*400,REASON_EFFECT)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end    
function s.thfilter(c)
	return c:IsSetCard(0x5caa) and c:GetOriginalType()&TYPE_MONSTER~=0
    	and c:IsFaceup() and c:IsAbleToHand()
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x5caa)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atkfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) 
    	and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_ONFIELD+LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_ONFIELD+LOCATION_EXTRA)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local hc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_ONFIELD+LOCATION_EXTRA,0,1,1,nil):GetFirst()
	if not hc then return end
    Duel.HintSelection(Group.FromCards(hc))
    if Duel.SendtoHand(hc,nil,REASON_EFFECT)~=0 and hc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,hc)
        local tc=Duel.GetFirstTarget()
        if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(1000)
			tc:RegisterEffect(e1)
        end    
    end    
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(id)
end    
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		local tg=g:GetMaxGroup(Card.GetAttack)
        local sg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
    	if tg:IsExists(Card.IsControler,1,nil,tp) then    		
        	for tc in aux.Next(sg) do
        		tc:RegisterFlagEffect(id+o,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
        	end
        else
        	for tc in aux.Next(sg) do
            	if tc:GetFlagEffect(id+o)>0 then
        			tc:ResetFlagEffect(id+o)
                end   
            end    
        end            
    end
end