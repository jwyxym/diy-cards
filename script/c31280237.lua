--唯我绝杰·马塞班恩
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280239)
	--超量召唤
	aux.AddXyzProcedure(c,nil,5,5,s.ovfilter,aux.Stringid(id,0),5,s.xyzop)
	c:EnableReviveLimit()
	--双召限制    
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCondition(s.lscon)
	e0:SetOperation(s.lsop)
	c:RegisterEffect(e0)
	--适用效果    
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(s.efop)
	c:RegisterEffect(e1)    
	--卡组检索    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
    e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--特殊召唤    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--不会被无效化    
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_ADJUST)
	e4:SetRange(0xff)
	e4:SetLabelObject(e3)
	e4:SetOperation(s.adjustop)
	c:RegisterEffect(e4)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		Duel.RegisterEffect(ge2,0)
	end
end
function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and not c:IsSetCard(0xacaa)
end    
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local sg=eg:Filter(s.cfilter,nil,e:GetHandler():GetOwner())
	local tc=sg:GetFirst()
	while tc do
		Duel.RegisterFlagEffect(tc:GetSummonPlayer(),id,RESET_PHASE+PHASE_END,0,1)
		tc=sg:GetNext()
	end
end
function s.ovfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)<=1 end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,EFFECT_FLAG_OATH,1)
end
function s.lscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
function s.lsop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
end
function s.splimit(e,c)
	return not c:IsSetCard(0xacaa)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFlagEffect(tp,id+o)~=0 then return end
    Duel.Hint(HINT_CARD,0,id)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	if g:GetCount()<=0 then return end
	Duel.ConfirmCards(1-tp,g)
    if g:GetClassCount(Card.GetCode)==g:GetCount() then    
    	Duel.RegisterFlagEffect(tp,id+o,0,0,0) 	    
    	local e1=Effect.CreateEffect(c)
    	e1:SetDescription(aux.Stringid(id,4))
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCondition(s.atkcon)
		e1:SetOperation(s.atkop)
   		e1:SetCountLimit(1)
		Duel.RegisterEffect(e1,tp)
    	local e2=Effect.CreateEffect(c)
    	e2:SetDescription(aux.Stringid(id,5))
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EVENT_PHASE+PHASE_END)
    	e2:SetCondition(s.dracon)
		e2:SetOperation(s.draop)
    	e2:SetCountLimit(1)
		Duel.RegisterEffect(e2,tp)
    	local e3=Effect.CreateEffect(c)
    	e3:SetDescription(aux.Stringid(id,6))
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCondition(s.descon)
		e3:SetOperation(s.desop)
   		e3:SetCountLimit(1)
		Duel.RegisterEffect(e3,tp)    	
    end    
    Duel.ShuffleDeck(tp)   			               		             	
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)==1
    	and Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)>0
end 
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)~=1 then return end
    Duel.Hint(HINT_CARD,0,id)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
    	for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(1000)
			tc:RegisterEffect(e1)
            local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2)
		end            
	end        
end        
function s.dracon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)==1 and Duel.IsPlayerCanDraw(tp,1) 
end
function s.draop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)~=1 then return end
    Duel.Hint(HINT_CARD,0,id)
	if Duel.Damage(1-tp,800,REASON_EFFECT)~=0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end        
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp and Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)==1
    	and Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_MZONE,nil)>0
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)~=1 then return end
    Duel.Hint(HINT_CARD,0,id)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=g:Select(tp,1,1,nil)
		Duel.HintSelection(dg)
		Duel.BreakEffect()
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
function s.thfilter(c)
	return c:IsSetCard(0xacaa) and c:IsAbleToHand()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) 
    	and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local res=false
    local sh=false
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	if g:GetCount()<=0 then return end
	Duel.ConfirmCards(1-tp,g)
    if g:GetClassCount(Card.GetCode)==g:GetCount() and c:IsRelateToEffect(e)
    	and c:IsFaceup() then
    	local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(800)
		c:RegisterEffect(e1)
        local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
    	res=true
    end
    if res then
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
            sh=true
		end
    end
    if not sh then
    	Duel.ShuffleDeck(tp)
    end    
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
function s.spfilter(c,e,tp)
	return c:IsCode(31280239) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
    	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end        
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			Duel.Overlay(tc,Group.FromCards(c))
		end
	end
end
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local e3=e:GetLabelObject()
	if Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)==0 then
		e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CAN_FORBIDDEN)
	else
		e3:SetProperty(EFFECT_FLAG_DELAY)
	end
end