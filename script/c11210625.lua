--竭灵炼魂 百歌
local s,id,o=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,11200430)
    c:EnableReviveLimit()
    --sp
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.sccon)
	e1:SetCost(s.sccost)
	e1:SetTarget(s.sctg)
	e1:SetOperation(s.scop)
	c:RegisterEffect(e1)
    --quick
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_EQUIP+CATEGORY_REMOVE+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() or Duel.GetTurnPlayer()~=tp 
end
function s.spfilter(c)
    return c:IsLevelAbove(5) and (c:IsRace(RACE_ZOMBIE) or c:IsRace(RACE_SPELLCASTER) or c:IsRace(RACE_ILLUSION))
end
function s.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,c:GetControler(),LOCATION_ONFIELD,0,1,nil) end
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD,0,nil,tp)
    local rg=g:Select(tp,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	if  #g>0 then   
         Duel.Remove(rg,POS_FACEUP,REASON_COST) 
    end
    e:SetLabelObject(rg:GetFirst())
end
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return  c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,true) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local lv=e:GetLabelObject():GetLevel()
    if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SpecialSummon(c,SUMMON_TYPE_RITUAL,tp,tp,true,true,POS_FACEUP) then
        local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2,true)
    end
end

function s.eqfilter(c)
    return c:IsRace(RACE_ZOMBIE) or c:IsRace(RACE_SPELLCASTER) or c:IsRace(RACE_ILLUSION)
end
function s.disfilter1(c,tp)
    return c:IsType(TYPE_EQUIP)  and c:IsControler(tp) and c:IsAbleToRemove()
end
function s.disfilter2(c)
    return c:IsFaceup() and aux.NegateAnyFilter(c) and c:GetFlagEffect(id)==0 
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local b1=Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
    local b2=Duel.IsExistingMatchingCard(s.disfilter1,tp,LOCATION_SZONE,0,1,nil) and Duel.IsExistingMatchingCard(s.disfilter2,tp,0,LOCATION_ONFIELD,1,nil)
    local dg=Duel.IsExistingMatchingCard(s.disfilter1,tp,LOCATION_SZONE,0,1,nil)
    local cg=Duel.IsExistingMatchingCard(s.disfilter2,tp,0,LOCATION_ONFIELD,1,nil)
    if b1 and b2 then
        Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
        Duel.SetOperationInfo(0,CATEGORY_REMOVE,dg,1,0,0)
        Duel.SetOperationInfo(0,CATEGORY_DISABLE,cg,1,0,0)
        elseif b1 then
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	    elseif b2 then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,dg,1,0,0)
        Duel.SetOperationInfo(0,CATEGORY_DISABLE,cg,1,0,0)
    end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local op=0
    local rm=e:GetHandler():GetEquipGroup():FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
    local dis=Duel.SelectMatchingCard(tp,s.disfilter2,tp,0,LOCATION_ONFIELD,1,1,nil)
	if  Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) and
    Duel.IsExistingMatchingCard(s.disfilter1,tp,LOCATION_SZONE,0,1,nil) and Duel.IsExistingMatchingCard(s.disfilter2,tp,0,LOCATION_ONFIELD,1,nil) then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) then
		op=0
	elseif Duel.IsExistingMatchingCard(s.disfilter1,tp,LOCATION_SZONE,0,1,nil) and Duel.IsExistingMatchingCard(s.disfilter2,tp,0,LOCATION_ONFIELD,1,nil) then
		op=1
	else
		return
	end
    if op==0 then
        local c=e:GetHandler()
	    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,c)
	    if #g>0 then
		    Duel.Equip(tp,g:GetFirst(),c,true)
		    local e1=Effect.CreateEffect(c)
		    e1:SetType(EFFECT_TYPE_SINGLE)
		    e1:SetCode(EFFECT_EQUIP_LIMIT)
		    e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		    e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		    e1:SetValue(s.eqlimit)
		    e1:SetLabelObject(c)
		    g:GetFirst():RegisterEffect(e1)
	    end
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e2:SetValue(aux.tgoval)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
        local atk=g:GetFirst():GetAttack()
        local def=g:GetFirst():GetDefense()
		if atk>0 then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_EQUIP)
			e3:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
			e3:SetCode(EFFECT_UPDATE_ATTACK)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			e3:SetValue(math.ceil(atk))
			g:GetFirst():RegisterEffect(e3)
		end
        if def>0 then
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_EQUIP)
			e4:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
			e4:SetCode(EFFECT_UPDATE_DEFENSE)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD)
			e4:SetValue(math.ceil(def))
			g:GetFirst():RegisterEffect(e4)
		end
	elseif op==1 then
		Duel.Remove(rm,POS_FACEUP,REASON_EFFECT)
        if #dis>0 then
		    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
		    Duel.HintSelection(dis)
            local c=e:GetHandler()
		    local tc=dis:GetFirst()
			local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_SET_ATTACK_FINAL)
		e4:SetValue(0)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e4)
		local e5=e4:Clone()
		e5:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e5)
		local e6=Effect.CreateEffect(c)
		e6:SetType(EFFECT_TYPE_SINGLE)
		e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e6:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e6:SetRange(LOCATION_MZONE)
		e6:SetReset(RESET_EVENT+RESETS_STANDARD)
		e6:SetValue(1)
		tc:RegisterEffect(e6)
		local e7=e6:Clone()
		e7:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e7:SetValue(s.fuslimit)
		tc:RegisterEffect(e7)
		local e8=e6:Clone()
		e8:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		tc:RegisterEffect(e8)
		local e9=e6:Clone()
		e9:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		tc:RegisterEffect(e9)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
            local e1=Effect.CreateEffect(c)
		    e1:SetType(EFFECT_TYPE_SINGLE)
		    e1:SetCode(EFFECT_DISABLE)
		    tc:RegisterEffect(e1)
		    local e2=Effect.CreateEffect(c)
		    e2:SetType(EFFECT_TYPE_SINGLE)
		    e2:SetCode(EFFECT_DISABLE_EFFECT)
		    e2:SetValue(RESET_TURN_SET)
		    tc:RegisterEffect(e2)
		    if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			tc:RegisterEffect(e3)
            end
		end
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function s.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end