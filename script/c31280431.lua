--无敌的主人公！弦卷心 ～璀璨阳光～
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280416)
	--同调召唤	
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(s.matfilter),1,99)
	c:EnableReviveLimit()
	--卡组检索    
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--改变等级
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o*10000)
    e2:SetCondition(s.lvcon)
    e2:SetCost(s.lvcost)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)    
	--当作调整    
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(s.tucon)
	e3:SetOperation(s.tuop)
	c:RegisterEffect(e3)
end
function s.matfilter(c)
	return aux.IsCodeListed(c,31280416)
end    
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) or aux.IsCodeListed(re:GetHandler(),31280416)
end
function s.thfilter(c)
	return aux.IsCodeOrListed(c,31280416) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then 
    	Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
	end        
end
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function s.cfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and aux.IsCodeListed(c,31280416) and c:IsLevelAbove(1)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
    	if e:GetLabel()==100 then
    		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,c)
        else return false end
    end        
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,c):GetFirst()
    if tc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,tc)
		Duel.ShuffleHand(tp)
    else
    	Duel.HintSelection(Group.FromCards(tc))
    end
    Duel.SetTargetCard(tc)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end    
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
    	local op=aux.SelectFromOptions(tp,
			{tc:IsLevelAbove(1),aux.Stringid(id,3),1},
			{tc:IsLevelAbove(2),aux.Stringid(id,4),2})
        local t={}
        for i=1,2 do
			if op==2 then
            	if tc:GetLevel()-i>0 then
            		table.insert(t,i)
                end
            elseif op==1 then
            	table.insert(t,i)
            end        
		end
        if #t==0 then return end
		local lv=Duel.AnnounceNumber(tp,table.unpack(t))        
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)		
        if op==1 then
			e1:SetValue(lv)
        elseif op==2 then
        	e1:SetValue(-lv)
        end    
        if tc:IsLocation(LOCATION_HAND) then
        	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
        elseif tc:IsLocation(LOCATION_MZONE) then
        	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        end    
		tc:RegisterEffect(e1)
        Duel.AdjustAll()
        local mg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE+LOCATION_HAND,0,nil,TYPE_MONSTER)
        if Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil,mg) 
        	and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
        	Duel.BreakEffect()
        	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil,mg)
			if g:GetCount()>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg=g:Select(tp,1,1,nil)
				Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
			end
        end
    end
end    
function s.tucon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
function s.tuop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TUNER)
	e1:SetValue(s.tnval)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)        
end
function s.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler())
end