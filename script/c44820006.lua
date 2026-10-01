--圣浊的追猎·翼骑
local s,id,o=GetID()
function s.initial_effect(c)
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
	--召唤    
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.sumcon)
	e4:SetTarget(s.sumtg)
	e4:SetOperation(s.sumop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
	--加入手卡    
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_SUMMON_SUCCESS)
	e6:SetProperty(EFFECT_FLAG_DELAY)
    e6:SetCountLimit(1,id+o*1000)
	e6:SetCondition(s.thcon)
	e6:SetTarget(s.thtg)
	e6:SetOperation(s.thop)
	c:RegisterEffect(e6)
	--放置    
    local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,3))
	e7:SetCategory(CATEGORY_SUMMON)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1,44821011)
	e7:SetTarget(s.pentg)
	e7:SetOperation(s.penop)
	c:RegisterEffect(e7)        
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
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
function s.sumfilter(c)
	return c:IsSetCard(0x6ce1) and c:IsSummonable(true,nil)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable() and Duel.IsPlayerCanSummon(tp) 
    	and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)    
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
		if tc then
			Duel.Summon(tp,tc,true,nil)
        end
	end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
function s.thfilter(c)
	return c:IsSetCard(0x6ce1) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
    	and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.tthfilter(c)
	return c:IsSetCard(0x6ce1) and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil):GetFirst()
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
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    if c:IsRelateToEffect(e) and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
    	and Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) and c:IsLocation(LOCATION_PZONE)
        and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
        Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
		if tc then    	
			Duel.Summon(tp,tc,true,nil)
        end
	end
end