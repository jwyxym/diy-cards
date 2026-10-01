--圣浊的要塞·天军
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,44820000)
    aux.EnablePendulumAttribute(c)
	--召唤规则
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(s.ttcon)
	e1:SetOperation(s.ttop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	e2:SetCondition(s.settcon)
	c:RegisterEffect(e2)
	--双召限制
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e0:SetTargetRange(1,0)
	e0:SetTarget(s.splimit)
	c:RegisterEffect(e0)
	local e3=e0:Clone()
	e3:SetCode(EFFECT_CANNOT_SUMMON)
    c:RegisterEffect(e3)    
	--卡组检索    
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES_SELF)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	--卡组检索
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCountLimit(1,id+o*1000)
	e5:SetCondition(s.athcon)
	e5:SetTarget(s.athtg)
	e5:SetOperation(s.athop)
	c:RegisterEffect(e5)
	--加入手卡    
    local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,3))
	e6:SetCategory(CATEGORY_TOHAND)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,44820011)
	e6:SetTarget(s.bhtg)
	e6:SetOperation(s.bhop)
	c:RegisterEffect(e6)    
end
function s.ttfilter(c)
	return c:IsLevelAbove(1) and c:IsType(TYPE_MONSTER) and c:IsReleasable(REASON_SUMMON|REASON_MATERIAL)
end
function s.exttfilter(c)
	return c:IsLevelAbove(1) and c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function s.httgcheck(g)
	if g:GetSum(Card.GetLevel)<=5 then return true end
	Duel.SetSelectedCard(g)
	return g:CheckWithSumGreater(Card.GetLevel,5)
end
function s.httcheck(g,tp)
	Duel.SetSelectedCard(g)
	return g:CheckWithSumGreater(Card.GetLevel,5) and Duel.GetMZoneCount(tp,g)>0
end
function s.ttcon(e,c,minc)
	if c==nil then return true end
    local tp=c:GetControler()
    local mg1=Duel.GetMatchingGroup(s.ttfilter,tp,LOCATION_MZONE,0,nil)
    local mg2=Duel.GetMatchingGroup(s.exttfilter,tp,LOCATION_EXTRA,0,nil)
    mg1:Merge(mg2)
	aux.GCheckAdditional=s.httgcheck
	local res=mg1:CheckSubGroup(s.httcheck,1,mg1:GetCount(),tp)
	aux.GCheckAdditional=nil
	return res
end
function s.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	local mg1=Duel.GetMatchingGroup(s.ttfilter,tp,LOCATION_MZONE,0,nil)
    local mg2=Duel.GetMatchingGroup(s.exttfilter,tp,LOCATION_EXTRA,0,nil)
    mg1:Merge(mg2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	aux.GCheckAdditional=s.httgcheck
	local sg=mg1:SelectSubGroup(tp,s.httcheck,false,1,mg1:GetCount(),tp)
	aux.GCheckAdditional=nil	
	c:SetMaterial(sg)
    local zg=sg:Filter(Card.IsLocation,nil,LOCATION_MZONE)
    local exg=sg:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
    if zg:GetCount()>0 then
		Duel.Release(zg,REASON_SUMMON+REASON_MATERIAL)
    end
    if exg:GetCount()>0 then
    	Duel.SendtoGrave(exg,REASON_SUMMON+REASON_MATERIAL)
    end
end
function s.settcon(e,c,minc)
	if not c then return true end
	return false
end
function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0x6ce1)
end
function s.thfilter(c)
	return c:IsCode(44820000) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) 
    	and e:GetHandler():IsDestructable() end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)    
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,tc)
            local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_DISCARD+REASON_EFFECT)
			if dg:GetCount()>0 then
				Duel.ShuffleHand(tp)
				Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
			end
        end
	end
end
function s.athcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
function s.athfilter(c)
	return c:IsSetCard(0x6ce1) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
function s.athtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.athfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.tthfilter(c)
	return c:IsSetCard(0x6ce1) and c:IsAbleToHand()
end
function s.athop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.athfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,tc)        
        if c:GetMaterial():GetSum(Card.GetLevel)==5 and Duel.IsExistingMatchingCard(s.tthfilter,tp,LOCATION_DECK,0,1,nil)
        	and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.tthfilter,tp,LOCATION_DECK,0,1,1,nil)
			if g:GetCount()>0 then
            	Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)    
            end 
        end
    end
end
function s.bhfilter(c)
	return c:IsSetCard(0x6ce1) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
    	and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.bhtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.bhfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil)
    	and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.bhop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.bhfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then
    	Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
end