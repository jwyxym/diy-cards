--械鳞龙魄 飓铁龙人
local s,id,o=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
    --种族视为机械族
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_CHANGE_RACE)
	e0:SetRange(LOCATION_MZONE+LOCATION_EXTRA+LOCATION_HAND)
	e0:SetValue(RACE_MACHINE)
	c:RegisterEffect(e0)
	--攻击力上升
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--灵摆调度    
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o*10000)
	e2:SetTarget(s.pentg)
	e2:SetOperation(s.penop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--不会成为对象
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.indcon)
	e4:SetValue(s.efilter)
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
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x5caa)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atkfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
    local res=false
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(800)
		tc:RegisterEffect(e1)
        res=true
	end
    if res and c:IsRelateToEffect(e) then
    	Duel.BreakEffect()
        Duel.Destroy(c,REASON_EFFECT)
    end
end
function s.pfilter(c,tp)
	return c:CheckUniqueOnField(tp) and not c:IsForbidden() 
end    
function s.txfilter(c,tp,g)
	return g:IsExists(s.pfilter,1,c,tp)
end
function s.fselect(g,tp)
	return g:IsExists(s.txfilter,1,nil,tp,g) and g:GetClassCount(Card.GetAttribute)==g:GetCount()
end
function s.filter(c)
	return c:IsSetCard(0x5caa) and c:IsType(TYPE_PENDULUM) 
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:CheckSubGroup(s.fselect,2,2,tp) 
    	and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) end
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local sg=g:SelectSubGroup(tp,s.fselect,false,2,2,tp)
    if not sg then return end
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local exc=sg:Select(tp,1,1,nil):GetFirst()
    if exc and Duel.SendtoExtraP(exc,nil,REASON_EFFECT)~=0 and exc:IsLocation(LOCATION_EXTRA) then
    	sg:RemoveCard(exc)
        local pg=sg:Filter(s.pfilter,nil,tp)
    	if pg:GetCount()>0 and (Duel.CheckLocation(tp,LOCATION_PZONE,0) 
        	or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then
        	Duel.MoveToField(pg:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
        end
	end
end
function s.indcon(e)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return false end
	local tg=g:GetMaxGroup(Card.GetAttack)
	return tg:IsExists(Card.IsControler,1,nil,e:GetHandlerPlayer())
end
function s.efilter(e,re,rp)
	return aux.tgoval(e,re,rp) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
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
        		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
        	end
        else
        	for tc in aux.Next(sg) do
            	if tc:GetFlagEffect(id)>0 then
        			tc:ResetFlagEffect(id)
                end   
            end    
        end            
    end
end