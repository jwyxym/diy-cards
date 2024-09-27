--孤独摇滚 后藤一里
local cm,m=GetID()

function cm.initial_effect(c)
	function cm.AddLinkProcedure(c,f,min,max,gf,string)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(string)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SPSUMMON_PROC)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetRange(LOCATION_EXTRA)
		if max==nil then max=c:GetLink() end
		e1:SetCondition(Auxiliary.LinkCondition(f,min,max,gf))
		e1:SetTarget(Auxiliary.LinkTarget(f,min,max,gf))
		e1:SetOperation(Auxiliary.LinkOperation(f,min,max,gf))
		e1:SetValue(SUMMON_TYPE_LINK)
		c:RegisterEffect(e1)
		return e1
	end
	function cm.AddLinkProcedure2(c,f,min,max,gf,string)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(string)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SPSUMMON_PROC)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetRange(LOCATION_EXTRA)
		if max==nil then max=c:GetLink() end
		e1:SetCondition(cm.LinkCondition(f,min,max,gf))
		e1:SetTarget(cm.LinkTarget(f,min,max,gf))
		e1:SetOperation(Auxiliary.LinkOperation(f,min,max,gf))
		e1:SetValue(SUMMON_TYPE_LINK)
		c:RegisterEffect(e1)
		return e1
	end
	--link summon
	cm.AddLinkProcedure(c,cm.lfcheck,2,2,cm.lcheck,aux.Stringid(m,7))
	cm.AddLinkProcedure2(c,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT),2,2,cm.lcheck2,aux.Stringid(m,8))
	c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(cm.regcon)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
    --atk record
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CUSTOM+10700054)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(cm.ad1op)
	c:RegisterEffect(e1)
	--atk check
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(cm.ad2op)
	c:RegisterEffect(e2)
	local e10=e2:Clone()
	e10:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e10)
	--tograve
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(m,0))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CUSTOM+10700055)
    e3:SetCountLimit(1,m)
	e3:SetCondition(cm.condition)
	e3:SetOperation(cm.operation)
	c:RegisterEffect(e3)
    --imm
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_IMMUNE_EFFECT)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
    e6:SetCondition(cm.atkcon)
	e6:SetValue(cm.efilter)
	c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EFFECT_SELF_DESTROY)
	e7:SetCondition(cm.tgcon)
	c:RegisterEffect(e7)
end

function cm.LConditionFilter(c,f,lc,e)
	return (c:IsFaceup() or not c:IsOnField() or e:IsHasProperty(EFFECT_FLAG_SET_AVAILABLE))
		and c:IsCanBeLinkMaterial(lc) and (c:IsLocation(0x04) or c:IsLinkType(TYPE_SPIRIT)) and (not f or f(c))
end

function cm.GetLinkMaterials(tp,f,lc,e)
	local mg=Duel.GetMatchingGroup(cm.LConditionFilter,tp,0x06,0,nil,f,lc,e)
	local mg2=Duel.GetMatchingGroup(Auxiliary.LExtraFilter,tp,LOCATION_HAND+LOCATION_SZONE,LOCATION_ONFIELD,nil,f,lc,tp)
	if mg2:GetCount()>0 then mg:Merge(mg2) end
	return mg
end

function cm.LinkCondition(f,minc,maxc,gf)
	return	function(e,c,og,lmat,min,max)
		if c==nil then return true end
		if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
		local minc=minc
		local maxc=maxc
		if min then
			if min>minc then minc=min end
			if max<maxc then maxc=max end
			if minc>maxc then return false end
		end
		local tp=c:GetControler()
		local mg=nil
		if og then
			mg=og:Filter(cm.LConditionFilter,nil,f,c,e)
		else
			mg=cm.GetLinkMaterials(tp,f,c,e)
		end
		if lmat~=nil then
			if not cm.LConditionFilter(lmat,f,c,e) then return false end
			mg:AddCard(lmat)
		end
		local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_LMATERIAL)
		if fg:IsExists(Auxiliary.MustMaterialCounterFilter,1,nil,mg) then return false end
		Duel.SetSelectedCard(fg)
		return mg:CheckSubGroup(Auxiliary.LCheckGoal,minc,maxc,tp,c,gf,lmat)
	end
end

function cm.LinkTarget(f,minc,maxc,gf)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,og,lmat,min,max)
		local minc=minc
		local maxc=maxc
		if min then
			if min>minc then minc=min end
			if max<maxc then maxc=max end
			if minc>maxc then return false end
		end
		local mg=nil
		if og then
			mg=og:Filter(cm.LConditionFilter,nil,f,c,e)
		else
			mg=cm.GetLinkMaterials(tp,f,c,e)
		end
		if lmat~=nil then
			if not cm.LConditionFilter(lmat,f,c,e) then return false end
			mg:AddCard(lmat)
		end
		local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_LMATERIAL)
		Duel.SetSelectedCard(fg)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
		local cancel=Duel.IsSummonCancelable()
		local sg=mg:SelectSubGroup(tp,Auxiliary.LCheckGoal,cancel,minc,maxc,tp,c,gf,lmat)
		if sg then
			sg:KeepAlive()
			e:SetLabelObject(sg)
			return true
		else return false end
	end
end

function cm.lfcheck(c)
	return not c:IsLink(2)
end

function cm.lcheck(g)
	return g:IsExists(Card.IsLinkAttribute,1,nil,ATTRIBUTE_DARK) or g:IsExists(Card.IsLinkRace,1,nil,RACE_PSYCHO)
end

function cm.lcheck2(g)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_SPIRIT)
end

function cm.regcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(cm.splimit)
	Duel.RegisterEffect(e1,tp)
end

function cm.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(m) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.ad1op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:ResetFlagEffect(110700054)
	c:RegisterFlagEffect(110700054,RESET_EVENT+RESETS_STANDARD,0,1,c:GetAttack())
end

function cm.ad2op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(110700054)==0 then
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+10700054,e,0,0,0,0)
	end
	if c:GetFlagEffectLabel(110700054)~=c:GetAttack() then
        if c:GetFlagEffectLabel(110700054)<c:GetAttack() then
		    Duel.RaiseSingleEvent(c,EVENT_CUSTOM+10700055,e,0,0,0,0)
        end
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+10700054,e,0,0,0,0)
	end
end

function cm.atkupconfilter(c)
	return not c:IsCode(m) or c:IsFacedown()
end

function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.atkupconfilter,tp,0x04,0,1,nil)
end

function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    if c:IsRelateToChain() and c:IsFaceup() then
        local num=Duel.SelectOption(tp,aux.Stringid(m,1),aux.Stringid(m,2))
        local e8=Effect.CreateEffect(c)
		e8:SetType(EFFECT_TYPE_SINGLE)
		e8:SetCode(EFFECT_UPDATE_ATTACK)
		e8:SetRange(LOCATION_MZONE)
		e8:SetLabel(num*10-8)
		e8:SetValue(cm.atkupfilter)
		e8:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e8)
    end
end

function cm.atkupfilter(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),e:Getlabel(),0)*500
end

function cm.tgcon(e)
	local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(Card.IsFaceup,c:GetControler(),0x04,0,nil)
	return Duel.GetCurrentPhase()==PHASE_END and c:IsStatus(STATUS_EFFECT_ENABLED) and #g==g:FilterCount(Card.IsCode,nil,m) and not cm.atkcon(e)
end

function cm.atkcon(e)
	return e:GetHandler():GetAttack()>=10000
end

function cm.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end