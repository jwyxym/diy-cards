--梅杜莎
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280146)
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
	--装备    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*10000)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
end
function s.thfilter(c)
	return aux.IsCodeOrListed(c,31280146) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.eqfilter(c,tp)
	return c:IsCode(31280146) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK,0,1,nil,tp) end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.mttg(e,c)
	local tc=c:GetEquipTarget()
	return tc and tc:IsFaceup() and tc:IsRace(RACE_REPTILE) and c:GetOriginalType()&TYPE_MONSTER~=0
end
function s.mtval(e,c,sumtype)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
function s.filter2(c,e,tp,m,f,chkf)
	return aux.IsMaterialListCode(c,31280146) and c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsFaceup() and c:IsRelateToEffect(e)) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    local res=false
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		if not Duel.Equip(tp,tc,c) then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetLabelObject(c)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		tc:RegisterEffect(e1)
        res=true
	end
    if res~=false then
    	local me=Effect.CreateEffect(e:GetHandler())
		me:SetType(EFFECT_TYPE_FIELD)
		me:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
		me:SetTargetRange(LOCATION_SZONE,0)
		me:SetTarget(s.mttg)
		me:SetValue(s.mtval)
		Duel.RegisterEffect(me,tp)
    	local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil):Filter(s.filter1,nil,e)
		local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		local mg3=nil
		local sg2=nil
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg3=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
		end
    	local b1=Duel.GetMatchingGroupCount(aux.nzatk,tp,0,LOCATION_MZONE,nil)>0
        local b2=sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0)
        if not (b1 or b2) or not Duel.SelectYesNo(tp,aux.Stringid(id,4)) then return end
        Duel.BreakEffect()
        local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},
			{b2,aux.Stringid(id,3),2})
        if op==1 then
        	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local sc=Duel.SelectMatchingCard(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()		
			if sc then
				Duel.HintSelection(Group.FromCards(sc))
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_ATTACK_FINAL)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetValue(0)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e1)
			end
        elseif op==2 then
        	local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
            ::cancel::
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
                if #mat1==0 then goto cancel end
				tc:SetMaterial(mat1)
				Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				Duel.BreakEffect()
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			else
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
                if #mat2==0 then goto cancel end
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			tc:CompleteProcedure()
		end
        me:Reset()        
    end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end